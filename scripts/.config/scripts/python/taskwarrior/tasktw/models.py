from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional


@dataclass
class TaskDraft:
    """Normalized task object before it is sent to Taskwarrior.

    Keep this object small and explicit. Taskwarrior fields are only converted
    into command-line arguments at the final boundary in taskwarrior.py.
    """

    description: str
    project: Optional[str] = None

    # UDA metadata fields
    program: Optional[str] = None
    scope: Optional[str] = None
    taskid: Optional[str] = None
    component: Optional[str] = None
    worktype: Optional[str] = None
    role: Optional[str] = None
    outcome: Optional[str] = None
    effort: Optional[str] = None

    # Standard Taskwarrior fields
    tags: list[str] = field(default_factory=list)
    due: str = ""
    priority: str = ""
    annotation: str = ""

    def preview(self) -> str:
        """Return a human-readable preview of the task."""

        lines = [
            "Preview",
            "-------",
            f"Description : {self.description}",
        ]
        if self.project:
            lines.append(f"Project     : {self.project}")

        meta = []
        for name in ("program", "scope", "taskid", "component", "worktype", "role", "outcome", "effort"):
            value = getattr(self, name)
            if value:
                meta.append(f"{name}={value}")
        if meta:
            lines.append(f"Metadata    : {' '.join(meta)}")

        if self.due:
            lines.append(f"Due         : {self.due}")
        if self.priority:
            lines.append(f"Priority    : {self.priority}")
        if self.tags:
            lines.append(f"Tags        : {' '.join('+' + t for t in self.tags)}")
        if self.annotation:
            lines.append(f"Annotation  : {self.annotation}")
        return "\n".join(lines)
