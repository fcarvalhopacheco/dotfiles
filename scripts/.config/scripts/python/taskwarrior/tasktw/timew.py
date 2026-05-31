from __future__ import annotations

"""Timewarrior setup helper."""


def run_timew_guide() -> int:
    print("Timewarrior integration guide")
    print("-----------------------------")
    print("Your workflow after installing the hook:")
    print("  task <id> start   # starts Timewarrior interval")
    print("  task <id> stop    # stops Timewarrior interval")
    print("  task <id> done    # completes task")
    print()
    print("Useful summaries:")
    print("  timew summary :day")
    print("  timew summary :week")
    print("  timew summary :month")
    print()
    print("Annual export:")
    print("  timew export 2026-01-01 - 2027-01-01 > ~/Desktop/timew_2026.json")
    print("  taskaddpy stats --year 2026 --timew-export ~/Desktop/timew_2026.json")
    return 0
