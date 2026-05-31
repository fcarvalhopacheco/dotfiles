#!/usr/bin/env python3
from __future__ import annotations

"""TaskAdd v0.8

Template-first Taskwarrior task creator with live project/name preview.
"""

import argparse
import os
import shutil
import sys
from pathlib import Path

from tasktw.config import AppConfig
from tasktw.models import TaskDraft
from tasktw.name_builder import NameBuilder, NameContext
from tasktw.prompts import PromptSession
from tasktw.stats import run_stats
from tasktw.taskwarrior import TaskwarriorClient
from tasktw.timew import run_timew_guide


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="taskadd", description="Template-first Taskwarrior task creator.")
    parser.add_argument("--config-dir", type=Path, default=None)
    parser.add_argument("--dry-run", action="store_true", help="Print command but do not run it.")
    parser.add_argument("--yes", "-y", action="store_true", help="Do not ask final confirmation.")
    parser.add_argument("--no-udas", action="store_true", help="Do not add UDA metadata fields.")
    parser.add_argument("--no-clear", action="store_true", help="Do not clear terminal at startup.")

    sub = parser.add_subparsers(dest="command")

    quick = sub.add_parser("quick", help="Quick capture an inbox task.")
    quick.add_argument("description", nargs="+", help="Task description.")

    add = sub.add_parser("add", help="Add task non-interactively.")
    add.add_argument("--template", required=True)
    add.add_argument("--id", dest="task_id", default="General")
    add.add_argument("--component", required=True)
    add.add_argument("--worktype", required=True)
    add.add_argument("--verb", default=None)
    add.add_argument("--details", default="")
    add.add_argument("--tags", default="")
    add.add_argument("--due", default="")
    add.add_argument("--priority", default="", choices=["", "H", "M", "L"])
    add.add_argument("--role", default=None)
    add.add_argument("--annotation", default="")

    preview = sub.add_parser("preview", help="Preview project/description naming without adding.")
    preview.add_argument("--template", required=True)
    preview.add_argument("--id", dest="task_id", default="General")
    preview.add_argument("--component", required=True)
    preview.add_argument("--worktype", required=True)
    preview.add_argument("--verb", default=None)
    preview.add_argument("--details", default="")

    sub.add_parser("templates", help="List templates.")
    sub.add_parser("vocab", help="List vocabulary summary.")
    sub.add_parser("doctor", help="Diagnose install/wrapper issues.")
    sub.add_parser("roles", help="Explain role choices.")
    sub.add_parser("udas", help="Explain UDA metadata fields.")
    sub.add_parser("timew", help="Show Timewarrior guide.")

    stats = sub.add_parser("stats", help="Generate annual-review statistics.")
    stats.add_argument("--year", default=None)
    stats.add_argument("--ytd", action="store_true")
    stats.add_argument("--from", dest="start", default=None)
    stats.add_argument("--to", dest="end", default=None)
    stats.add_argument("--last-days", default=None)
    stats.add_argument("--program", default=None)
    stats.add_argument("--export", default=None)
    stats.add_argument("--timew-export", default=None)
    stats.add_argument("--format", choices=["md", "json", "csv"], default="md")
    stats.add_argument("--output", "-o", default=None)
    stats.add_argument("--no-pending", action="store_true")

    return parser.parse_args()


def maybe_clear(args: argparse.Namespace) -> None:
    if args.no_clear or os.environ.get("TASKADD_NO_CLEAR") == "1":
        return
    if args.command in {"templates", "vocab", "doctor", "roles", "udas", "stats", "timew", "preview"}:
        return
    os.system("clear")


def load_config(config_dir: Path | None) -> AppConfig:
    if config_dir is None:
        config_dir = Path(__file__).resolve().parent / "config"
    return AppConfig.load(config_dir)


def command_quick(args: argparse.Namespace, client: TaskwarriorClient) -> int:
    desc = " ".join(args.description).strip()
    if not desc:
        print("No description provided.")
        return 1
    return client.add_task(TaskDraft(description=desc, tags=["inbox"]))


def make_draft_from_args(args: argparse.Namespace, config: AppConfig) -> TaskDraft | None:
    template = config.templates.get(args.template)
    if not template:
        print(f"Unknown template: {args.template}")
        print("Run: taskadd templates")
        return None

    raw_task_id = template.normalize_id(args.task_id)
    verb = args.verb or config.default_verb_for_worktype(args.worktype)

    nb = NameBuilder()
    ctx = NameContext(
        program=template.program,
        scope=template.default_scope,
        taskid=raw_task_id,
        component=args.component,
        worktype=args.worktype,
        verb=verb,
        details=args.details,
    )

    role = getattr(args, 'role', None) or config.infer_role(template.program, template.default_scope, args.component, args.worktype)
    raw_tags = getattr(args, 'tags', '')
    tags = config.clean_tags(raw_tags.split(',')) if raw_tags else []
    tags = config.apply_automatic_tags(tags, args.worktype, template.default_scope, args.component)

    warning = nb.warning_for_taskid(ctx)
    if warning:
        print(f"Naming warning: {warning}")

    verb_warning = nb.warning_for_verb_worktype(verb, args.worktype)
    if verb_warning:
        print(f"Verb/worktype warning: {verb_warning}")

    return TaskDraft(
        description=nb.description(ctx),
        project=nb.project(ctx),
        program=template.program,
        scope=template.default_scope,
        taskid=nb.normalized_taskid(ctx),
        component=args.component,
        worktype=args.worktype,
        role=role,
        tags=tags,
        due=getattr(args, "due", ""),
        priority=getattr(args, "priority", ""),
        annotation=getattr(args, "annotation", ""),
    )


def command_add(args: argparse.Namespace, config: AppConfig, client: TaskwarriorClient) -> int:
    draft = make_draft_from_args(args, config)
    if draft is None:
        return 1
    return client.add_task(draft)


def command_preview(args: argparse.Namespace, config: AppConfig) -> int:
    draft = make_draft_from_args(args, config)
    if draft is None:
        return 1
    print(draft.preview())
    return 0


def list_templates(config: AppConfig) -> int:
    print("Available templates:\n")
    for key, tmpl in config.templates.items():
        print(f"  {key:<22} {tmpl.label}")
    return 0


def list_vocab(config: AppConfig) -> int:
    print("Vocabulary summary:\n")
    print(f"Programs:    {', '.join(config.vocabulary.get('programs', []))}")
    print(f"Components:  {len(config.vocabulary.get('components_all', []))} total")
    print(f"Work types:  {len(config.vocabulary.get('worktypes_all', []))} total")
    print(f"Verbs:       {len(config.vocabulary.get('verbs_all', []))} total")
    print(f"Tags:        {len(config.vocabulary.get('tags_all', []))} total")
    return 0


def doctor() -> int:
    print("TaskAdd doctor")
    print("--------------")
    print(f"Python executable : {sys.executable}")
    print(f"taskadd.py path   : {Path(__file__).resolve()}")
    print(f"task command      : {shutil.which('task') or 'NOT FOUND'}")
    print(f"timew command     : {shutil.which('timew') or 'NOT FOUND'}")
    print()
    print("Good alias examples:")
    print("  alias taskaddpy=\"$HOME/.dotfiles/scripts/.config/scripts/zsh/taskadd\"")
    print("  alias taskaddpy='python3 $HOME/.dotfiles/scripts/.config/scripts/python/taskwarrior/taskadd.py'")
    return 0


def explain_roles() -> int:
    print("Role guidance")
    print("-------------")
    print("Role is the hat/responsibility you are wearing, not the specific action.")
    print("Analyst: analysis/QC/calibration/model validation.")
    print("DataManager: publishing, archiving, data products, database/data dissemination.")
    print("Developer: code, automation, websites, Sphinx, GitHub pipelines.")
    print("SystemAdministrator: servers, backups, QNAP/NAS/Linux.")
    print("ChiefScientist: cruise leadership/reporting as CS.")
    print("MarineResearchSpecialist: default HOT/WHOTS professional technical role.")
    return 0


def explain_udas() -> int:
    print("UDA guidance")
    print("------------")
    print("UDA = User Defined Attribute. These are structured fields saved on each task.")
    print()
    rows = [
        ("program",   "Big domain",              "HOT, WHOTS, SOEST, PERSONAL"),
        ("scope",     "Container/type of work",  "Cruise, Deployment, AnnualReport, Infrastructure, Mercator"),
        ("taskid",    "Anchor ID",               "H364, W22, 2025, Step1, helu, General"),
        ("component", "Object/system",           "CTD, AutoSal, Blueprint, Server, GlassBalls"),
        ("worktype",  "Kind of work",            "DataProcessing, Planning, Forecasting, Backup"),
        ("role",      "Your responsibility/hat", "Analyst, DataManager, Developer, ChiefScientist"),
        ("effort",    "Optional hours estimate", "2, 4, 12"),
        ("outcome",   "Result after completion", "published, archived, fixed, submitted"),
    ]
    for name, meaning, examples in rows:
        print(f"  {name:<10} {meaning:<24} {examples}")
    return 0


def run_stats_command(args: argparse.Namespace) -> int:
    stats_args = []
    for flag, value in [
        ("--year", args.year), ("--from", args.start), ("--to", args.end),
        ("--last-days", args.last_days), ("--program", args.program),
        ("--export", args.export), ("--timew-export", args.timew_export),
        ("--format", args.format), ("--output", args.output),
    ]:
        if value:
            stats_args.extend([flag, str(value)])
    if args.ytd:
        stats_args.append("--ytd")
    if args.no_pending:
        stats_args.append("--no-pending")
    return run_stats(stats_args)


def main() -> int:
    args = parse_args()
    maybe_clear(args)
    config = load_config(args.config_dir)
    client = TaskwarriorClient(dry_run=args.dry_run, use_udas=not args.no_udas, assume_yes=args.yes)

    if args.command == "quick":
        return command_quick(args, client)
    if args.command == "add":
        return command_add(args, config, client)
    if args.command == "preview":
        return command_preview(args, config)
    if args.command == "templates":
        return list_templates(config)
    if args.command == "vocab":
        return list_vocab(config)
    if args.command == "doctor":
        return doctor()
    if args.command == "roles":
        return explain_roles()
    if args.command == "udas":
        return explain_udas()
    if args.command == "timew":
        return run_timew_guide()
    if args.command == "stats":
        return run_stats_command(args)

    session = PromptSession(config)
    draft = session.create_task()
    if draft is None:
        print("Cancelled.")
        return 1
    return client.add_task(draft)


if __name__ == "__main__":
    raise SystemExit(main())
