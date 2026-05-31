#!/usr/bin/env python3
from __future__ import annotations

"""Optional validation hook.

Do not install until the Python app is stable.
"""

import json
import re
import sys


def main() -> int:
    task = json.loads(sys.stdin.readline())
    print(json.dumps(task, separators=(",", ":")))

    desc = task.get("description", "")
    if re.match(r"^\[[^\]]+\]\[[^\]]+\]\[[^\]]+\]", desc):
        print("Warning: old bracket-style description detected. Prefer readable descriptions.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
