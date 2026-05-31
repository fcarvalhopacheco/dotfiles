from __future__ import annotations

import re
import shlex
import subprocess

from tasktw.models import TaskDraft


class TaskwarriorClient:
    """Thin wrapper around the `task` command."""

    def __init__(self, dry_run: bool = False, use_udas: bool = True, assume_yes: bool = False) -> None:
        self.dry_run = dry_run
        self.use_udas = use_udas
        self.assume_yes = assume_yes

    def build_add_command(self, draft: TaskDraft) -> list[str]:
        """Build a safe argv list for `task add`.

        Do not build a shell string here. Use argv so colons and spaces are
        passed correctly to Taskwarrior.
        """

        cmd = ["task", "add", draft.description]

        if draft.project:
            cmd.append(f"project:{draft.project}")

        if draft.due:
            cmd.append(f"due:{draft.due}")
        if draft.priority:
            cmd.append(f"priority:{draft.priority}")

        if self.use_udas:
            uda_fields = {
                "program": draft.program,
                "scope": draft.scope,
                "taskid": draft.taskid,
                "component": draft.component,
                "worktype": draft.worktype,
                "role": draft.role,
                "outcome": draft.outcome,
                "effort": draft.effort,
            }
            for key, value in uda_fields.items():
                if value:
                    cmd.append(f"{key}:{value}")

        for tag in draft.tags:
            tag = tag.lstrip("+")
            if tag:
                cmd.append(f"+{tag}")

        return cmd

    def add_task(self, draft: TaskDraft) -> int:
        print()
        print(draft.preview())
        print()

        cmd = self.build_add_command(draft)
        print("Command:")
        print(" ".join(shlex.quote(part) for part in cmd))
        print()

        if self.dry_run:
            print("Dry run: task not added.")
            return 0

        if not self.assume_yes:
            confirm = input("Add task? [y/N]: ").strip().lower()
            if confirm not in {"y", "yes"}:
                print("Cancelled.")
                return 1

        completed = subprocess.run(cmd, check=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if completed.stdout:
            print(completed.stdout, end="")
        if completed.returncode != 0:
            return completed.returncode

        if draft.annotation:
            task_id = self._extract_created_task_id(completed.stdout)
            if task_id:
                subprocess.run(["task", task_id, "annotate", draft.annotation], check=False)
            else:
                print("Task added, but annotation lookup failed. Add manually with: task <id> annotate ...")

        return 0

    @staticmethod
    def _extract_created_task_id(output: str) -> str:
        match = re.search(r"Created task\s+(\d+)", output or "")
        return match.group(1) if match else ""
