#!/usr/bin/env python3
"""
SilkCircuit Status Line - Installer
====================================

Points Claude Code at the SilkCircuit status line.

Claude Code owns ~/.claude/settings.json and rewrites it as hooks, plugins, and
permissions change, so dotfiles deliberately does not track it. This merges in
the single statusLine key we own and leaves everything else untouched.

Usage:
    python3 install-statusline.py
"""

import json
import shutil
import sys
from pathlib import Path

# Python on Windows encodes stdout as cp1252 by default, which cannot represent
# the checkmark below and would abort the install over a decoration
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ANSI colors (SilkCircuit palette)
C = {
    "green": "\033[38;2;80;250;123m",
    "yellow": "\033[38;2;241;250;140m",
    "cyan": "\033[38;2;128;255;234m",
    "purple": "\033[38;2;225;53;255m",
    "red": "\033[38;2;255;99;99m",
    "reset": "\033[0m",
}

# Git Bash strips unquoted backslashes, so this stays in forward-slash form on
# every platform, Windows included
STATUS_LINE = {
    "type": "command",
    "command": "~/.claude/statusline-command.sh",
}


def color(text: str, style: str) -> str:
    return f"{C[style]}{text}{C['reset']}"


def main() -> int:
    settings_path = Path.home() / ".claude" / "settings.json"
    settings_path.parent.mkdir(parents=True, exist_ok=True)

    settings: dict = {}
    if settings_path.is_file():
        raw = settings_path.read_text(encoding="utf-8").strip()
        if raw:
            try:
                settings = json.loads(raw)
            except json.JSONDecodeError as exc:
                print(color(f"✗ {settings_path} is not valid JSON: {exc}", "red"))
                print(color("  Leaving it alone; fix it and re-run.", "yellow"))
                return 1

    if settings.get("statusLine") == STATUS_LINE:
        print(color("Status line already configured", "cyan"))
        return 0

    if settings_path.is_file():
        backup = settings_path.with_suffix(".json.bak")
        shutil.copy2(settings_path, backup)
        print(color(f"Backed up to {backup}", "yellow"))

    settings["statusLine"] = STATUS_LINE
    settings_path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")

    print(
        color("SilkCircuit", "purple")
        + " status line wired into "
        + color(str(settings_path), "cyan")
        + " "
        + color("✓", "green")
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
