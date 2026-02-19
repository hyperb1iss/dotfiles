#!/usr/bin/env python3
"""
Claude Code Security - Installer
=================================

Installs the damage-control hooks into your Claude Code configuration.
Preserves existing hooks and settings while adding security protection.

Usage:
    python install.py [--global|--project] [--no-safe-tools]

Options:
    --global         Install to ~/.claude/settings.json (default)
    --project        Install to ./.claude/settings.json
    --no-safe-tools  Skip adding safe tool allow rules
    --minimal        Only add hooks, no permission rules
"""

import argparse
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

# ANSI colors (SilkCircuit palette)
C = {
    "green": "\033[38;2;80;250;123m",
    "yellow": "\033[38;2;241;250;140m",
    "cyan": "\033[38;2;128;255;234m",
    "purple": "\033[38;2;225;53;255m",
    "red": "\033[38;2;255;99;99m",
    "reset": "\033[0m",
    "bold": "\033[1m",
}


def color(text: str, *styles: str) -> str:
    """Apply color/style to text."""
    prefix = "".join(C.get(s, "") for s in styles)
    return f"{prefix}{text}{C['reset']}"


def log(icon: str, message: str) -> None:
    """Print formatted log message."""
    print(f"  {icon}  {message}")


SCRIPT_DIR = Path(__file__).parent.resolve()


def load_safe_tools() -> list[str]:
    """Load and flatten safe-tools.yaml into permission rules."""
    safe_tools_file = SCRIPT_DIR / "safe-tools.yaml"
    if not safe_tools_file.exists():
        return []

    try:
        import yaml

        data = yaml.safe_load(safe_tools_file.read_text())
    except ImportError:
        # Basic parsing without PyYAML
        data = parse_safe_tools_basic(safe_tools_file.read_text())

    rules: list[str] = []

    # Flatten bash categories
    bash = data.get("bash", {})
    for category, items in bash.items():
        if isinstance(items, list):
            rules.extend(items)

    # Add web rules
    rules.extend(data.get("web", []))

    # Add search rules
    rules.extend(data.get("search", []))

    # Add MCP rules
    rules.extend(data.get("mcp", []))

    return rules


def parse_safe_tools_basic(content: str) -> dict[str, Any]:
    """Basic parser for safe-tools.yaml without PyYAML."""
    import re

    result: dict[str, Any] = {"bash": {}, "web": [], "search": [], "mcp": []}
    current_section = None
    current_category = None

    for line in content.split("\n"):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        # Top-level sections
        if line.startswith("bash:"):
            current_section = "bash"
            continue
        elif line.startswith("web:"):
            current_section = "web"
            continue
        elif line.startswith("search:"):
            current_section = "search"
            continue
        elif line.startswith("mcp:"):
            current_section = "mcp"
            continue

        # Bash categories
        if current_section == "bash" and line.startswith("  ") and line.endswith(":"):
            current_category = stripped.rstrip(":")
            result["bash"][current_category] = []
            continue

        # Items
        if stripped.startswith('- "'):
            match = re.search(r'"([^"]+)"', stripped)
            if match:
                item = match.group(1)
                if current_section == "bash" and current_category:
                    result["bash"][current_category].append(item)
                elif current_section in ("web", "search", "mcp"):
                    result[current_section].append(item)

    return result


# Hook configurations to add
SECURITY_HOOKS = {
    "PreToolUse": [
        {
            "matcher": "Bash",
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {SCRIPT_DIR}/damage-control.py",
                    "timeout": 5,
                }
            ],
        },
        {
            "matcher": "Edit",
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {SCRIPT_DIR}/damage-control.py",
                    "timeout": 5,
                }
            ],
        },
        {
            "matcher": "Write",
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {SCRIPT_DIR}/damage-control.py",
                    "timeout": 5,
                }
            ],
        },
        {
            "matcher": "Read",
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {SCRIPT_DIR}/damage-control.py",
                    "timeout": 5,
                }
            ],
        },
    ],
}

# Default deny rules (backup defense even if hooks fail)
DEFAULT_DENY = [
    "Bash(git push:*)",
    "Bash(git push --force:*)",
    "Bash(git reset --hard:*)",
    "Bash(rm -rf /:*)",
    "Bash(sudo rm:*)",
]

# Default ask rules
DEFAULT_ASK = [
    "Bash(rm:*)",
    "Bash(kubectl delete:*)",
    "Bash(kubectl exec:*)",
    "Bash(docker rm:*)",
    "Bash(docker stop:*)",
]


def is_security_hook(hook_entry: dict) -> bool:
    """Check if a hook entry is from this security module."""
    for hook in hook_entry.get("hooks", []):
        cmd = str(hook.get("command", ""))
        if "damage-control.py" in cmd or "security/damage-control" in cmd:
            return True
    return False


def backup_settings(settings_file: Path) -> Path | None:
    """Create timestamped backup of settings file."""
    if not settings_file.exists():
        return None

    backup = settings_file.with_suffix(f".{datetime.now():%Y%m%d-%H%M%S}.bak")
    shutil.copy2(settings_file, backup)
    return backup


def load_settings(settings_file: Path) -> dict:
    """Load existing settings or return empty dict."""
    if settings_file.exists():
        try:
            return json.loads(settings_file.read_text())
        except json.JSONDecodeError:
            return {}
    return {}


def merge_hooks(existing_hooks: dict, new_hooks: dict) -> dict:
    """Merge new hooks with existing, removing old security hooks."""
    merged = {}

    for event, event_hooks in existing_hooks.items():
        # Filter out old security hooks
        merged[event] = [h for h in event_hooks if not is_security_hook(h)]

    # Add new security hooks
    for event, event_hooks in new_hooks.items():
        if event not in merged:
            merged[event] = []
        merged[event].extend(event_hooks)

    return merged


def merge_permissions(existing: dict, deny: list, ask: list) -> dict:
    """Merge permission rules, avoiding duplicates."""
    merged = existing.copy()

    # Ensure lists exist
    merged.setdefault("deny", [])
    merged.setdefault("ask", [])
    merged.setdefault("allow", [])

    # Add deny rules if not present
    for rule in deny:
        if rule not in merged["deny"]:
            merged["deny"].append(rule)

    # Add ask rules if not present
    for rule in ask:
        if rule not in merged["ask"]:
            merged["ask"].append(rule)

    return merged


def install(
    settings_file: Path,
    include_safe_tools: bool = True,
    minimal: bool = False,
) -> bool:
    """Install security hooks to settings file."""
    print()
    print(color("  Claude Code Security Installer", "purple", "bold"))
    print(color("  ─" * 20, "purple"))
    print()

    # Backup existing settings
    backup = backup_settings(settings_file)
    if backup:
        log("📦", f"Backed up to {color(backup.name, 'yellow')}")

    # Load existing settings
    settings = load_settings(settings_file)

    # Merge hooks
    existing_hooks = settings.get("hooks", {})
    settings["hooks"] = merge_hooks(existing_hooks, SECURITY_HOOKS)
    log("🔒", f"Added PreToolUse hooks for {color('Bash, Edit, Write, Read', 'cyan')}")

    if not minimal:
        # Merge permissions
        existing_perms = settings.get("permissions", {})
        settings["permissions"] = merge_permissions(existing_perms, DEFAULT_DENY, DEFAULT_ASK)
        log("🛡️", f"Added {color(str(len(DEFAULT_DENY)), 'red')} deny rules, {color(str(len(DEFAULT_ASK)), 'yellow')} ask rules")

        # Add safe tools
        if include_safe_tools:
            safe_tools = load_safe_tools()
            if safe_tools:
                allow_list = settings["permissions"].setdefault("allow", [])
                added = 0
                for tool in safe_tools:
                    if tool not in allow_list:
                        allow_list.append(tool)
                        added += 1
                log("✅", f"Added {color(str(added), 'green')} safe tool allow rules")

    # Ensure parent directory exists
    settings_file.parent.mkdir(parents=True, exist_ok=True)

    # Write settings
    settings_file.write_text(json.dumps(settings, indent=2))
    log("✨", f"Saved to {color(str(settings_file), 'green')}")

    print()
    print(color("  Installation complete!", "green", "bold"))
    print()
    print(f"  Patterns file: {color(str(SCRIPT_DIR / 'patterns.yaml'), 'cyan')}")
    print(f"  Safe tools:    {color(str(SCRIPT_DIR / 'safe-tools.yaml'), 'cyan')}")
    print(f"  Edit these files to customize rules.")
    print()

    return True


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Install Claude Code security hooks")
    parser.add_argument(
        "--project",
        action="store_true",
        help="Install to project settings (./.claude/settings.json)",
    )
    parser.add_argument(
        "--global",
        dest="global_install",
        action="store_true",
        default=True,
        help="Install to user settings (~/.claude/settings.json) [default]",
    )
    parser.add_argument(
        "--no-safe-tools",
        action="store_true",
        help="Skip adding safe tool allow rules",
    )
    parser.add_argument(
        "--minimal",
        action="store_true",
        help="Only add hooks, no permission rules",
    )
    parser.add_argument(
        "--list-safe-tools",
        action="store_true",
        help="Print all safe tool rules and exit",
    )
    args = parser.parse_args()

    # List mode
    if args.list_safe_tools:
        tools = load_safe_tools()
        print(json.dumps(tools, indent=2))
        return 0

    if args.project:
        settings_file = Path.cwd() / ".claude" / "settings.json"
    else:
        settings_file = Path.home() / ".claude" / "settings.json"

    success = install(
        settings_file,
        include_safe_tools=not args.no_safe_tools,
        minimal=args.minimal,
    )
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
