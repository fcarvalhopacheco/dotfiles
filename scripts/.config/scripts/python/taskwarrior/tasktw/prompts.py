from __future__ import annotations

"""Interactive prompt layer for taskadd.

v0.8 live-preview philosophy
----------------------------
The user should never reach the final preview and be surprised by the final
Taskwarrior name. This prompt layer refreshes a small "Current draft" panel
after important choices.

The naming logic lives in tasktw.name_builder so it can also be reused later by
migration scripts.
"""

from dataclasses import dataclass, field
from difflib import get_close_matches
from typing import Sequence

from tasktw.config import AppConfig
from tasktw.models import TaskDraft
from tasktw.name_builder import NameBuilder, NameContext
from tasktw.templates import TaskTemplate
from tasktw.terminal import Terminal


def print_columns(items: Sequence[str], columns: int = 2, width: int = 28) -> None:
    for idx, item in enumerate(items, start=1):
        print(f"{idx:>2}) {item:<{width}}", end="")
        if idx % columns == 0:
            print()
    if len(items) % columns != 0:
        print()


def dedupe(items: Sequence[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for item in items:
        key = item.lower()
        if key not in seen:
            result.append(item)
            seen.add(key)
    return result


@dataclass
class DraftContext:
    template: TaskTemplate
    task_id: str = "General"
    component: str = ""
    worktype: str = ""
    verb: str = ""
    details: str = ""
    role: str = ""
    due: str = ""
    tags: list[str] = field(default_factory=list)

    @property
    def program(self) -> str:
        return self.template.program

    @property
    def scope(self) -> str:
        return self.template.default_scope


class PromptSession:
    """Interactive session for creating one Taskwarrior task."""

    def __init__(self, config: AppConfig) -> None:
        self.config = config
        self.term = Terminal()
        self.name_builder = NameBuilder()

    # ------------------------------------------------------------------
    # Main flow
    # ------------------------------------------------------------------

    def create_task(self) -> TaskDraft | None:
        self.print_header()
        print("1) Guided structured task")
        print("2) Quick inbox capture")
        print("3) Cancel")
        mode = input("Mode [1]: ").strip() or "1"

        if mode == "2":
            return self.quick_capture()
        if mode == "3":
            return None
        return self.guided()

    def print_header(self) -> None:
        print(self.term.green(self.term.bold("TaskAdd")))
        print(self.term.dim("Template-first Taskwarrior capture with live preview"))

    def quick_capture(self) -> TaskDraft | None:
        desc = input("Description: ").strip()
        if not desc:
            return None
        return TaskDraft(description=desc, tags=["inbox"])

    def guided(self) -> TaskDraft | None:
        template = self.choose_template()
        if template is None:
            return None

        ctx = DraftContext(template)
        self.show_draft(ctx, note="Template selected. Choose an ID only when it adds information.")

        ctx.task_id = self.ask_id(template)
        self.show_draft(ctx, note="Project preview refreshed after ID selection.")

        ctx.component = self.choose_value(
            title="Component",
            suggestions=template.components,
            all_values=self.config.vocabulary.get("components_all", []),
            help_text="Component is the noun: instrument, system, deliverable, software piece, or life area affected by the task.",
        ) or ""
        if not ctx.component:
            return None
        self.show_draft(ctx)

        ctx.worktype = self.choose_value(
            title="Work type",
            suggestions=template.worktypes,
            all_values=self.config.vocabulary.get("worktypes_all", []),
            help_text="Work type is the kind of work: DataProcessing, Calibration, ReportWriting, Automation, Troubleshooting, Planning, etc.",
        ) or ""
        if not ctx.worktype:
            return None
        self.show_draft(ctx)

        ctx.verb = self.choose_verb(ctx.worktype)
        verb_warning = self.name_builder.warning_for_verb_worktype(ctx.verb, ctx.worktype)
        if verb_warning:
            self.term.warning(verb_warning)
        self.show_draft(ctx, note="Description preview now uses the selected verb.")

        ctx.details = self.ask_description_details(ctx)
        if not ctx.details:
            return None
        self.show_draft(ctx, note="This is the final description unless you change it.")

        ctx.tags = self.ask_tags(template, ctx.worktype, template.default_scope, ctx.component)
        ctx.due = self.ask_due()
        ctx.role = self.config.infer_role(template.program, template.default_scope, ctx.component, ctx.worktype)

        self.show_draft(ctx, note=f"Inferred role: {ctx.role}")

        priority = ""
        annotation = ""
        more = input("More options? priority/role/annotation [y/N]: ").strip().lower()
        if more in {"y", "yes"}:
            priority = input("Priority [none/H/M/L]: ").strip().upper()
            if priority not in {"", "H", "M", "L"}:
                priority = ""

            print(f"Role [Enter = {ctx.role}, ? help/list]: ", end="")
            role_choice = input().strip()
            if role_choice == "?":
                self.explain_roles()
                ctx.role = self.choose_role(default=ctx.role)
            elif role_choice:
                ctx.role = self.match_choice(role_choice, self.config.vocabulary.get("roles", [])) or role_choice

            annotation = input("Annotation/note [skip]: ").strip().strip('"').strip("'")

        nctx = self.to_name_context(ctx)
        final_taskid = self.name_builder.normalized_taskid(nctx)

        return TaskDraft(
            description=self.name_builder.description(nctx),
            project=self.name_builder.project(nctx),
            program=template.program,
            scope=template.default_scope,
            taskid=final_taskid,
            component=ctx.component,
            worktype=ctx.worktype,
            role=ctx.role,
            tags=ctx.tags,
            due=ctx.due,
            priority=priority,
            annotation=annotation,
        )

    # ------------------------------------------------------------------
    # Live preview
    # ------------------------------------------------------------------

    def to_name_context(self, ctx: DraftContext) -> NameContext:
        return NameContext(
            program=ctx.program,
            scope=ctx.scope,
            taskid=ctx.task_id,
            component=ctx.component or "Other",
            worktype=ctx.worktype or "Planning",
            verb=ctx.verb or self.config.default_verb_for_worktype(ctx.worktype or "Planning"),
            details=ctx.details,
        )

    def show_draft(self, ctx: DraftContext, note: str | None = None) -> None:
        nctx = self.to_name_context(ctx)
        role = ctx.role or self.config.infer_role(ctx.program, ctx.scope, ctx.component or "Other", ctx.worktype or "Planning")

        self.term.section("Current draft")
        print(f"Project : {self.term.green(self.name_builder.project(nctx))}")
        print(f"Desc    : {self.name_builder.description(nctx)}")
        print(f"Meta    : {self.name_builder.metadata_preview(nctx, role=role)}")
        if ctx.tags:
            print(f"Tags    : {' '.join('+' + t for t in ctx.tags)}")
        if ctx.due:
            print(f"Due     : {ctx.due}")

        warning = self.name_builder.warning_for_taskid(nctx)
        if warning:
            self.term.warning(warning)
        if note:
            self.term.hint(note)

    # ------------------------------------------------------------------
    # Prompts
    # ------------------------------------------------------------------

    def choose_template(self) -> TaskTemplate | None:
        templates = list(self.config.templates.values())
        self.term.section("What kind of task?")
        print_columns([t.label for t in templates], columns=1, width=62)
        print("number | /term search | q cancel")

        while True:
            choice = input("Template [1]: ").strip() or "1"
            if choice.lower() == "q":
                return None
            if choice.startswith("/"):
                term = choice[1:].lower()
                if not term:
                    print("Type /term to search, e.g. /hot or /personal.")
                    continue
                matches = [t for t in templates if term in t.label.lower() or term in t.key.lower()]
                if not matches:
                    self.term.warning("No matches.")
                    continue
                print_columns([t.label for t in matches], columns=1, width=62)
                sub = input("Choose search result number: ").strip()
                if sub.isdigit() and 1 <= int(sub) <= len(matches):
                    return matches[int(sub) - 1]
                continue
            if choice.isdigit() and 1 <= int(choice) <= len(templates):
                return templates[int(choice) - 1]
            self.term.warning("Invalid choice.")

    def ask_id(self, template: TaskTemplate) -> str:
        self.term.section("Anchor / ID")
        print(template.id_prompt)
        print(self.term.dim("Use this for cruise/deployment/year/phase/system. Press Enter when the template already gives enough context."))

        raw = input("ID [General]: ").strip()
        task_id = template.normalize_id(raw)

        # Immediate feedback, but final normalization also happens in NameBuilder.
        if task_id.lower() == template.default_scope.lower():
            self.term.warning(
                f"'{task_id}' already equals the scope '{template.default_scope}'. "
                "Using General so the project will not repeat the same word."
            )
            return "General"
        if task_id.lower() == template.program.lower():
            self.term.warning(f"'{task_id}' already equals the program '{template.program}'. Using General.")
            return "General"

        print(f"Using ID: {task_id}")
        return task_id

    def choose_value(self, title: str, suggestions: Sequence[str], all_values: Sequence[str], help_text: str) -> str | None:
        suggestions = dedupe(suggestions)
        all_values = dedupe(all_values)

        while True:
            self.term.section(title)
            if suggestions:
                print(f"Enter = {suggestions[0]}")
            print_columns(suggestions, columns=2, width=26)
            print("number/name | /term search | all | c custom | ? help | q cancel")
            choice = input(f"{title}: ").strip()

            if choice.lower() == "q":
                return None
            if choice == "":
                return suggestions[0] if suggestions else None
            if choice == "?":
                print(help_text)
                continue
            if choice == "all":
                selected = self.choose_from_values(f"All {title}", all_values)
                if selected:
                    return selected
                continue
            if choice == "c":
                custom = input("Custom value: ").strip()
                return custom or None
            if choice.startswith("/"):
                term = choice[1:].lower()
                if not term:
                    print("Type /term to search, e.g. /ctd or /report.")
                    continue
                matches = [v for v in all_values if term in v.lower()]
                if not matches:
                    self.term.warning("No matches.")
                    continue
                selected = self.choose_from_values(f"Search results for /{term}", matches)
                if selected:
                    return selected
                continue

            selected = self.match_choice(choice, suggestions) or self.match_choice(choice, all_values)
            if selected:
                return selected
            self.term.warning("Invalid choice. Type ? for help.")

    def choose_from_values(self, title: str, values: Sequence[str]) -> str | None:
        values = dedupe(values)
        self.term.section(title)
        print_columns(values, columns=2, width=26)
        while True:
            choice = input("Choose number/name, or Enter to go back: ").strip()
            if not choice:
                return None
            selected = self.match_choice(choice, values)
            if selected:
                return selected
            self.term.warning("Invalid choice.")

    def match_choice(self, choice: str, values: Sequence[str]) -> str | None:
        if choice.isdigit() and 1 <= int(choice) <= len(values):
            return values[int(choice) - 1]
        for value in values:
            if choice.lower() == value.lower():
                return value
        return None

    def choose_verb(self, worktype: str) -> str:
        default = self.config.default_verb_for_worktype(worktype)
        common = self.config.vocabulary.get("verbs_common", [])
        all_verbs = self.config.vocabulary.get("verbs_all", [])

        self.term.section(f"Verb [Enter = {default}]")
        print_columns(common, columns=3, width=18)
        print("Enter default | number/name | /term search | all | c custom")

        while True:
            choice = input("Verb: ").strip()
            if not choice:
                return default
            if choice == "all":
                selected = self.choose_from_values("All verbs", all_verbs)
                if selected:
                    return selected
                continue
            if choice == "c":
                custom = input("Custom verb: ").strip()
                return custom or default
            if choice.startswith("/"):
                term = choice[1:].lower()
                if not term:
                    print("Type /term to search verbs, e.g. /build.")
                    continue
                matches = [v for v in all_verbs if term in v.lower()]
                if not matches:
                    self.term.warning("No matches.")
                    continue
                selected = self.choose_from_values(f"Verb search /{term}", matches)
                if selected:
                    return selected
                continue

            selected = self.match_choice(choice, common) or self.match_choice(choice, all_verbs)
            if selected:
                return selected
            self.term.warning("Invalid verb.")

    def ask_description_details(self, ctx: DraftContext) -> str:
        self.term.section(f"Description = {ctx.verb} + details")
        nctx = self.to_name_context(ctx)
        default = self.name_builder.suggested_details(nctx)
        print(f"Suggested details: {self.term.green(default)}")
        if ctx.template.examples:
            print("Examples:")
            for ex in ctx.template.examples[:2]:
                print(f"  - {ex}")
        details = input("Details [Enter = suggested]: ").strip() or default

        extra = input("Extra context/target [skip, e.g. 'to hahana', 'for FSM review']: ").strip()
        if extra:
            if extra.lower().startswith(("to ", "for ", "with ", "after ", "before ", "on ", "in ", "from ")):
                details = f"{details} {extra}"
            else:
                details = f"{details} for {extra}"

        return details

    def ask_tags(self, template: TaskTemplate, worktype: str, scope: str, component: str) -> list[str]:
        self.term.section("Tags")
        suggestions = template.tags
        print("Suggested:", ", ".join(suggestions))
        print("Use comma-separated tags. Use snake_case: post_cruise, year_review, deep_cast.")
        print("Type ? for common tag groups.")
        raw = input("Tags [skip]: ").strip()

        if raw == "?":
            vocab = self.config.vocabulary
            for group in ("tag_workflow", "tag_report", "tag_tool", "tag_people", "tag_science", "tag_personal"):
                print(f"{group}: {', '.join(vocab.get(group, []))}")
            raw = input("Tags [skip]: ").strip()

        tags = self.config.clean_tags(raw.split(",")) if raw else []
        tags = self.validate_tags(tags)
        return self.config.apply_automatic_tags(tags, worktype, scope, component)

    def validate_tags(self, tags: list[str]) -> list[str]:
        known = self.config.known_tags()
        fixed: list[str] = []

        for tag in tags:
            if not tag:
                continue

            if tag == "hot":
                ans = input("Tag 'hot' is redundant because program=HOT. Drop it? [Y/n]: ").strip().lower()
                if ans in {"", "y", "yes"}:
                    continue

            if tag == "start":
                ans = input("Tag 'start' is usually not useful. Use +next instead? [Y/n]: ").strip().lower()
                tag = "next" if ans in {"", "y", "yes"} else tag

            if tag not in known:
                matches = get_close_matches(tag, sorted(known), n=1, cutoff=0.78)
                if matches:
                    ans = input(f"Unknown tag '{tag}'. Did you mean '{matches[0]}'? [Y/n]: ").strip().lower()
                    if ans in {"", "y", "yes"}:
                        tag = matches[0]
                else:
                    ans = input(f"Unknown tag '{tag}'. Keep it? [y/N]: ").strip().lower()
                    if ans not in {"y", "yes"}:
                        continue

            if tag not in fixed:
                fixed.append(tag)

        return fixed

    def ask_due(self) -> str:
        self.term.section("Due")
        print("Due date is optional. Use real deadlines only.")
        print("Tip: 'today' may become midnight and appear overdue. Prefer 'eod' for end of day.")
        print("Examples: eod, tomorrow, friday, 2weeks, 2026-05-30")
        due = input("Due [none]: ").strip()

        if due.lower() == "today":
            ans = input("Convert 'today' to 'eod' to avoid immediate overdue? [Y/n]: ").strip().lower()
            if ans in {"", "y", "yes"}:
                return "eod"

        return due

    def choose_role(self, default: str = "MarineResearchSpecialist") -> str:
        roles = self.config.vocabulary.get("roles", ["None"])
        self.term.section("Role")
        print_columns(roles, columns=2, width=30)
        choice = input(f"Role [{default}]: ").strip()
        if not choice:
            return default
        return self.match_choice(choice, roles) or choice

    def explain_roles(self) -> None:
        self.term.section("Role guidance")
        print("Role = your responsibility/hat, not the specific action.")
        print("Analyst = analysis/QC/calibration interpretation.")
        print("DataManager = publishing, archiving, formal data products, database/data dissemination.")
        print("Developer = code, automation, website/Sphinx/GitHub pipelines.")
        print("SystemAdministrator = servers, backups, QNAP/NAS/Linux.")
        print("ChiefScientist = cruise leadership/reporting as CS.")
        print("MarineResearchSpecialist = default HOT/WHOTS professional technical role.")
