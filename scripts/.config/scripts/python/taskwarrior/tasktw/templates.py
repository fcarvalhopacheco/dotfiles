from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class TaskTemplate:
    """A task creation template.

    program + default_scope are fixed by the template. taskid/component/worktype
    are selected by the user. The final project path is produced by NameBuilder.
    """

    key: str
    label: str
    program: str
    default_scope: str
    id_prompt: str
    id_prefix: str
    components: list[str]
    worktypes: list[str]
    tags: list[str]
    examples: list[str]

    @classmethod
    def from_dict(cls, key: str, data: dict) -> "TaskTemplate":
        return cls(
            key=key,
            label=data["label"],
            program=data["program"],
            default_scope=data["default_scope"],
            id_prompt=data.get("id_prompt", "ID"),
            id_prefix=data.get("id_prefix", ""),
            components=list(data.get("components", [])),
            worktypes=list(data.get("worktypes", [])),
            tags=list(data.get("tags", [])),
            examples=list(data.get("examples", [])),
        )

    def normalize_id(self, raw: str | None) -> str:
        """Normalize cruise/deployment IDs.

        HOT 364 -> H364
        WHOTS 22 -> W22
        blank -> General
        """

        raw = (raw or "").strip().replace(" ", "")
        if not raw:
            return "General"

        if self.id_prefix:
            # Accept H364, HOT-364, 364 for HOT; W22, WHOTS-22, 22 for WHOTS.
            cleaned = raw.replace("-", "")
            prefix = self.id_prefix.upper()
            if cleaned.upper().startswith(prefix):
                return prefix + cleaned[len(prefix):]
            if prefix == "H" and cleaned.upper().startswith("HOT"):
                return "H" + cleaned[3:]
            if prefix == "W" and cleaned.upper().startswith("WHOTS"):
                return "W" + cleaned[5:]
            return f"{prefix}{cleaned}"

        return raw
