from __future__ import annotations

import os
import sys


class Terminal:
    """Small ANSI styling helper with graceful fallback."""

    def __init__(self, use_color: bool | None = None) -> None:
        if use_color is None:
            use_color = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
        self.use_color = use_color

    def style(self, text: str, code: str) -> str:
        if not self.use_color:
            return text
        return f"\033[{code}m{text}\033[0m"

    def bold(self, text: str) -> str:
        return self.style(text, "1")

    def dim(self, text: str) -> str:
        return self.style(text, "2")

    def blue(self, text: str) -> str:
        return self.style(text, "34")

    def green(self, text: str) -> str:
        return self.style(text, "32")

    def yellow(self, text: str) -> str:
        return self.style(text, "33")

    def red(self, text: str) -> str:
        return self.style(text, "31")

    def section(self, title: str) -> None:
        print()
        print(self.blue(self.bold(title)))
        print(self.dim("─" * max(8, len(title))))

    def hint(self, text: str) -> None:
        print(self.dim(text))

    def warning(self, text: str) -> None:
        print(self.yellow(text))

    def error(self, text: str) -> None:
        print(self.red(text))
