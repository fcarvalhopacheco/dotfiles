from __future__ import annotations

"""Taskwarrior analytics and annual-review reporting.

Taskwarrior custom reports are good for simple lists. This module is for richer
annual-review analytics, date ranges, and optional Timewarrior export summaries.
"""

import argparse
import csv
import json
import subprocess
from collections import Counter
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any


def parse_task_date(value: str | None) -> datetime | None:
    if not value:
        return None
    value = str(value).strip()
    for fmt in ("%Y%m%dT%H%M%SZ", "%Y%m%dT%H%M%S", "%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(value, fmt)
            return dt.replace(tzinfo=timezone.utc) if dt.tzinfo is None else dt
        except ValueError:
            pass
    return None


def parse_range_date(value: str | None, *, end: bool = False) -> datetime | None:
    if not value:
        return None
    dt = parse_task_date(value)
    if not dt:
        raise ValueError(f"Could not parse date: {value}")
    if len(value.strip()) == 10 and end:
        return dt + timedelta(days=1)
    return dt


def year_range(year: int) -> tuple[datetime, datetime]:
    return datetime(year, 1, 1, tzinfo=timezone.utc), datetime(year + 1, 1, 1, tzinfo=timezone.utc)


def in_range(dt: datetime | None, start: datetime, end: datetime) -> bool:
    return bool(dt and start <= dt < end)


def month_key(dt: datetime | None) -> str:
    return f"{dt.year:04d}-{dt.month:02d}" if dt else "Unspecified"


def task_value(task: dict[str, Any], key: str, default: str = "Unspecified") -> str:
    value = task.get(key)
    return default if value is None or value == "" else str(value)


def tags_of(task: dict[str, Any]) -> list[str]:
    tags = task.get("tags") or []
    return [str(t) for t in tags] if isinstance(tags, list) else []


def task_matches_program(task: dict[str, Any], program: str | None) -> bool:
    if not program:
        return True
    program = program.upper()
    if task_value(task, "program", "").upper() == program:
        return True
    return task_value(task, "project", "").upper().startswith(program + ".")


def task_is_review_candidate(task: dict[str, Any]) -> bool:
    tags = set(tags_of(task))
    return bool(tags.intersection({"year_review", "rcuh_review", "annual_report", "deliverable", "publication", "published", "submitted"})) or task_value(task, "component", "") in {"YearReview", "PerformanceReview", "AnnualReport"}


def task_is_infrastructure(task: dict[str, Any]) -> bool:
    return (
        task_value(task, "scope", "") in {"Infrastructure", "Server", "Backup", "Website", "Database", "Mercator"}
        or task_value(task, "component", "") in {"Server", "Backup", "Borg", "QNAP", "NAS", "Website", "Database", "CurrentStatus", "Workflow", "MercatorCopernicus"}
        or bool(set(tags_of(task)).intersection({"qnap", "borg", "server", "website", "linux", "github", "mercator", "copernicus"}))
    )


def count_by(tasks: list[dict[str, Any]], key: str) -> Counter:
    return Counter(task_value(t, key) for t in tasks)


def count_tags(tasks: list[dict[str, Any]]) -> Counter:
    c = Counter()
    for t in tasks:
        c.update(tags_of(t))
    return c


def count_completed_by_month(tasks: list[dict[str, Any]]) -> Counter:
    c = Counter()
    for t in tasks:
        if task_value(t, "status", "") == "completed":
            c[month_key(parse_task_date(t.get("end")))] += 1
    return c


def sum_effort_by(tasks: list[dict[str, Any]], key: str) -> Counter:
    c = Counter()
    for t in tasks:
        try:
            effort = float(t.get("effort"))
        except (TypeError, ValueError):
            continue
        c[task_value(t, key)] += effort
    return c


def export_tasks() -> list[dict[str, Any]]:
    completed = subprocess.run(["task", "export"], check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if completed.returncode != 0:
        raise RuntimeError(completed.stderr.strip() or "task export failed")
    return json.loads(completed.stdout or "[]")


def load_tasks(path: Path | None = None) -> list[dict[str, Any]]:
    return json.loads(path.read_text()) if path else export_tasks()


def load_timewarrior_export(path: Path | None) -> list[dict[str, Any]]:
    if not path:
        return []
    data = json.loads(path.read_text() or "[]")
    return data if isinstance(data, list) else []


def timew_interval_seconds(interval: dict[str, Any]) -> float:
    start = parse_task_date(interval.get("start"))
    end = parse_task_date(interval.get("end"))
    if not start or not end:
        return 0.0
    return max(0.0, (end - start).total_seconds())


def summarize_timew(intervals: list[dict[str, Any]], start: datetime, end: datetime) -> dict[str, Any]:
    by_tag = Counter()
    by_month = Counter()
    total = 0.0
    for i in intervals:
        begin = parse_task_date(i.get("start"))
        if not in_range(begin, start, end):
            continue
        seconds = timew_interval_seconds(i)
        total += seconds
        for tag in i.get("tags") or []:
            by_tag[str(tag)] += seconds
        by_month[month_key(begin)] += seconds
    return {
        "total_hours": round(total / 3600, 2),
        "hours_by_tag": {k: round(v / 3600, 2) for k, v in by_tag.most_common()},
        "hours_by_month": {k: round(v / 3600, 2) for k, v in sorted(by_month.items())},
    }


@dataclass
class ReportData:
    start: str
    end: str
    program_filter: str | None
    completed_count: int
    active_pending_count: int
    review_candidate_count: int
    completed_by_month: dict[str, int]
    completed_by_program: dict[str, int]
    completed_by_scope: dict[str, int]
    completed_by_component: dict[str, int]
    completed_by_worktype: dict[str, int]
    completed_by_role: dict[str, int]
    top_tags: dict[str, int]
    effort_by_component: dict[str, float]
    timewarrior: dict[str, Any]
    accomplishments: list[str]
    infrastructure_accomplishments: list[str]
    active_review_candidates: list[str]


def task_line(task: dict[str, Any], include_status: bool = False) -> str:
    status = task_value(task, "status", "")
    context = " / ".join(v for v in [
        task_value(task, "program", ""),
        task_value(task, "scope", ""),
        task_value(task, "taskid", ""),
        task_value(task, "component", ""),
        task_value(task, "worktype", ""),
    ] if v and v != "Unspecified") or task_value(task, "project", "")
    prefix = f"**{status}** — **{context}**" if include_status else f"**{context}**"
    tags = ", ".join(tags_of(task))
    if tags:
        return f"- {prefix} — {task_value(task, 'description', '')} _(tags: {tags})_"
    return f"- {prefix} — {task_value(task, 'description', '')}"


def build_report_data(tasks: list[dict[str, Any]], start: datetime, end: datetime, program: str | None = None, include_pending: bool = True, timewarrior_export: Path | None = None) -> ReportData:
    relevant = [t for t in tasks if task_matches_program(t, program)]
    completed = [t for t in relevant if task_value(t, "status", "") == "completed" and in_range(parse_task_date(t.get("end")), start, end)]
    active = [t for t in relevant if task_value(t, "status", "") == "pending"] if include_pending else []
    review_candidates = [t for t in active if task_is_review_candidate(t)]
    infra = [t for t in completed if task_is_infrastructure(t)]

    completed_sorted = sorted(completed, key=lambda t: parse_task_date(t.get("end")) or datetime.min.replace(tzinfo=timezone.utc), reverse=True)
    impact = [t for t in completed_sorted if task_is_review_candidate(t)]
    for t in completed_sorted:
        if t not in impact:
            impact.append(t)
        if len(impact) >= 75:
            break

    timew = summarize_timew(load_timewarrior_export(timewarrior_export), start, end) if timewarrior_export else {}

    return ReportData(
        start=start.date().isoformat(),
        end=(end - timedelta(days=1)).date().isoformat(),
        program_filter=program,
        completed_count=len(completed),
        active_pending_count=len(active),
        review_candidate_count=len(review_candidates),
        completed_by_month=dict(sorted(count_completed_by_month(completed).items())),
        completed_by_program=dict(count_by(completed, "program").most_common()),
        completed_by_scope=dict(count_by(completed, "scope").most_common()),
        completed_by_component=dict(count_by(completed, "component").most_common()),
        completed_by_worktype=dict(count_by(completed, "worktype").most_common()),
        completed_by_role=dict(count_by(completed, "role").most_common()),
        top_tags=dict(count_tags(completed).most_common(30)),
        effort_by_component={k: round(v, 2) for k, v in sum_effort_by(completed, "component").most_common()},
        timewarrior=timew,
        accomplishments=[task_line(t) for t in impact[:75]],
        infrastructure_accomplishments=[task_line(t) for t in infra[:50]],
        active_review_candidates=[task_line(t, include_status=True) for t in review_candidates[:50]],
    )


def md_count_table(title: str, counts: dict, unit: str = "Count") -> list[str]:
    lines = [f"## {title}", "", f"| Value | {unit} |", "|---|---:|"]
    if not counts:
        lines.append("| _none_ | 0 |")
    else:
        for value, count in counts.items():
            lines.append(f"| {value} | {count} |")
    lines.append("")
    return lines


def render_markdown(data: ReportData) -> str:
    title = f"# Taskwarrior Review Report — {data.start} to {data.end}"
    if data.program_filter:
        title += f" — {data.program_filter.upper()}"

    lines = [
        title, "",
        "## Executive snapshot", "",
        f"- Completed tasks in range: **{data.completed_count}**",
        f"- Active pending tasks now: **{data.active_pending_count}**",
        f"- Active review candidates: **{data.review_candidate_count}**",
        "",
    ]

    if data.timewarrior:
        lines.extend(["## Timewarrior snapshot", "", f"- Total tracked hours: **{data.timewarrior.get('total_hours', 0)}**", ""])
        lines.extend(md_count_table("Tracked hours by tag", data.timewarrior.get("hours_by_tag", {}), unit="Hours"))
        lines.extend(md_count_table("Tracked hours by month", data.timewarrior.get("hours_by_month", {}), unit="Hours"))

    lines.extend(md_count_table("Completed by month", data.completed_by_month))
    lines.extend(md_count_table("Completed by program", data.completed_by_program))
    lines.extend(md_count_table("Completed by scope", data.completed_by_scope))
    lines.extend(md_count_table("Completed by component", data.completed_by_component))
    lines.extend(md_count_table("Completed by work type", data.completed_by_worktype))
    lines.extend(md_count_table("Completed by role", data.completed_by_role))
    lines.extend(md_count_table("Top tags", data.top_tags))

    if data.effort_by_component:
        lines.extend(md_count_table("Effort by component", data.effort_by_component, unit="Hours"))

    lines.extend(["## Accomplishment candidates", ""])
    lines.extend(data.accomplishments or ["_No completed accomplishment candidates found._"])
    lines.extend(["", "## Infrastructure/system accomplishments", ""])
    lines.extend(data.infrastructure_accomplishments or ["_No infrastructure completions found._"])
    lines.extend(["", "## Active review candidates", ""])
    lines.extend(data.active_review_candidates or ["_No active review candidates found._"])
    lines.append("")
    return "\n".join(lines)


def render_json(data: ReportData) -> str:
    return json.dumps(asdict(data), indent=2)


def render_csv_summary(data: ReportData) -> str:
    import io
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["section", "value", "count"])
    for section, counts in {
        "completed_by_month": data.completed_by_month,
        "completed_by_program": data.completed_by_program,
        "completed_by_scope": data.completed_by_scope,
        "completed_by_component": data.completed_by_component,
        "completed_by_worktype": data.completed_by_worktype,
        "completed_by_role": data.completed_by_role,
        "top_tags": data.top_tags,
    }.items():
        for value, count in counts.items():
            writer.writerow([section, value, count])
    return output.getvalue()


def build_stats_command_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="taskadd stats")
    date_group = parser.add_mutually_exclusive_group()
    date_group.add_argument("--year", type=int, default=None)
    date_group.add_argument("--ytd", action="store_true")
    parser.add_argument("--from", dest="start", default=None)
    parser.add_argument("--to", dest="end", default=None)
    parser.add_argument("--last-days", type=int, default=None)
    parser.add_argument("--program", default=None)
    parser.add_argument("--export", type=Path, default=None)
    parser.add_argument("--timew-export", type=Path, default=None)
    parser.add_argument("--format", choices=["md", "json", "csv"], default="md")
    parser.add_argument("--output", "-o", type=Path, default=None)
    parser.add_argument("--no-pending", action="store_true")
    return parser


def resolve_report_range(args: argparse.Namespace) -> tuple[datetime, datetime]:
    now = datetime.now(timezone.utc)
    if args.last_days:
        return now - timedelta(days=args.last_days), now
    if args.year:
        return year_range(args.year)
    if args.ytd:
        return datetime(now.year, 1, 1, tzinfo=timezone.utc), now
    if args.start or args.end:
        start = parse_range_date(args.start, end=False) if args.start else datetime(now.year, 1, 1, tzinfo=timezone.utc)
        end = parse_range_date(args.end, end=True) if args.end else now
        if not start or not end:
            raise ValueError("Invalid date range")
        return start, end
    return year_range(now.year)


def run_stats(argv: list[str]) -> int:
    parser = build_stats_command_parser()
    args = parser.parse_args(argv)
    start, end = resolve_report_range(args)
    tasks = load_tasks(args.export)
    data = build_report_data(tasks, start, end, program=args.program, include_pending=not args.no_pending, timewarrior_export=args.timew_export)

    if args.format == "json":
        rendered = render_json(data)
    elif args.format == "csv":
        rendered = render_csv_summary(data)
    else:
        rendered = render_markdown(data)

    if args.output:
        args.output.write_text(rendered)
        print(f"Wrote {args.output}")
    else:
        print(rendered)
    return 0
