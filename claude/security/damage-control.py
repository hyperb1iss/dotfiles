#!/usr/bin/env python3
"""
Claude Code Damage Control - PreToolUse Hook
=============================================

Defense-in-depth protection that intercepts tool calls before execution.
Blocks dangerous commands and protects sensitive files.

Exit Codes:
  0 - Allow (with optional JSON for ask/context)
  2 - Block (stderr shown to Claude as error)

Usage:
  Configured as PreToolUse hook in ~/.claude/settings.json
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Any

# ANSI colors for terminal output (SilkCircuit palette)
COLORS = {
    "red": "\033[38;2;255;99;99m",
    "yellow": "\033[38;2;241;250;140m",
    "cyan": "\033[38;2;128;255;234m",
    "purple": "\033[38;2;225;53;255m",
    "green": "\033[38;2;80;250;123m",
    "reset": "\033[0m",
}


def color(text: str, name: str) -> str:
    """Apply color to text."""
    return f"{COLORS.get(name, '')}{text}{COLORS['reset']}"


def load_patterns() -> dict[str, Any]:
    """Load security patterns from YAML file."""
    # Look for patterns.yaml in same directory as this script
    script_dir = Path(__file__).parent
    patterns_file = script_dir / "patterns.yaml"

    if not patterns_file.exists():
        # Fallback: check ~/.claude/hooks/security/
        patterns_file = Path.home() / ".claude" / "hooks" / "security" / "patterns.yaml"

    if not patterns_file.exists():
        print(f"Warning: patterns.yaml not found", file=sys.stderr)
        return {}

    try:
        import yaml

        return yaml.safe_load(patterns_file.read_text())
    except ImportError:
        # Fallback: basic YAML parsing for simple structure
        return parse_simple_yaml(patterns_file.read_text())


def parse_simple_yaml(content: str) -> dict:
    """Basic YAML parser for patterns file (no external deps)."""
    # This is a minimal parser - install PyYAML for full support
    import re

    result: dict = {"bash": {"block": [], "ask": [], "allow": []}}
    current_section = None
    current_subsection = None

    for line in content.split("\n"):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        # Detect sections
        if line.startswith("bash:"):
            current_section = "bash"
        elif line.startswith("  block:"):
            current_subsection = "block"
        elif line.startswith("  ask:"):
            current_subsection = "ask"
        elif line.startswith("  allow:"):
            current_subsection = "allow"
        elif line.startswith("    - pattern:"):
            if current_section and current_subsection:
                pattern_match = re.search(r"pattern:\s*['\"](.+?)['\"]", line)
                if pattern_match:
                    pattern = pattern_match.group(1)
                    result[current_section][current_subsection].append(
                        {"pattern": pattern, "reason": "Security rule"}
                    )

    return result


def expand_path(path: str) -> str:
    """Expand ~ and environment variables in path."""
    return os.path.expandvars(os.path.expanduser(path))


def check_path_patterns(file_path: str, patterns: dict) -> tuple[str | None, str | None]:
    """Check if file path matches any protected path patterns."""
    paths_config = patterns.get("paths", {})

    # Check zero access paths
    for pattern in paths_config.get("zero_access", []):
        expanded = expand_path(pattern)
        if Path(file_path).match(pattern.lstrip("~").lstrip("/")) or expanded in file_path:
            return "block", f"Zero access path: {pattern}"

    # Check read-only paths (for edit/write)
    for pattern in paths_config.get("read_only", []):
        expanded = expand_path(pattern)
        if Path(file_path).match(pattern.lstrip("~").lstrip("/")) or expanded in file_path:
            return "block", f"Read-only path: {pattern}"

    return None, None


def check_bash_command(command: str, patterns: dict) -> tuple[str, str | None]:
    """
    Check bash command against security patterns.

    Returns:
        ("allow", None) - Command is safe
        ("ask", reason) - Command needs user confirmation
        ("block", reason) - Command is blocked
    """
    bash_patterns = patterns.get("bash", {})

    # First check allow patterns (these override blocks)
    for rule in bash_patterns.get("allow", []):
        pattern = rule.get("pattern", "")
        flags = re.IGNORECASE if rule.get("flags") == "IGNORECASE" else 0
        try:
            if re.search(pattern, command, flags):
                return "allow", None
        except re.error:
            continue

    # Then check block patterns
    for rule in bash_patterns.get("block", []):
        pattern = rule.get("pattern", "")
        reason = rule.get("reason", "Blocked by security policy")
        flags = re.IGNORECASE if rule.get("flags") == "IGNORECASE" else 0
        action = rule.get("action", "block")  # Can be overridden to "ask"

        try:
            if re.search(pattern, command, flags):
                return action, reason
        except re.error:
            continue

    # Finally check ask patterns
    for rule in bash_patterns.get("ask", []):
        pattern = rule.get("pattern", "")
        reason = rule.get("reason", "Requires confirmation")
        flags = re.IGNORECASE if rule.get("flags") == "IGNORECASE" else 0

        try:
            if re.search(pattern, command, flags):
                return "ask", reason
        except re.error:
            continue

    return "allow", None


def check_file_tool(tool_name: str, file_path: str, patterns: dict) -> tuple[str, str | None]:
    """Check Edit/Write tool against security patterns."""
    tool_key = tool_name.lower()
    tool_patterns = patterns.get(tool_key, {})

    # Check path-level protection first
    action, reason = check_path_patterns(file_path, patterns)
    if action:
        return action, reason

    # Check tool-specific patterns
    for rule in tool_patterns.get("block", []):
        pattern = rule.get("pattern", "")
        reason = rule.get("reason", "Blocked by security policy")
        try:
            if re.search(pattern, file_path):
                return "block", reason
        except re.error:
            continue

    for rule in tool_patterns.get("ask", []):
        pattern = rule.get("pattern", "")
        reason = rule.get("reason", "Requires confirmation")
        try:
            if re.search(pattern, file_path):
                return "ask", reason
        except re.error:
            continue

    return "allow", None


def output_ask_response(reason: str) -> None:
    """Output JSON response requesting user confirmation."""
    response = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }
    print(json.dumps(response))


def main() -> int:
    """Main entry point for the damage control hook."""
    # Read input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Failed to parse input: {e}", file=sys.stderr)
        return 0  # Don't block on parse errors

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Load patterns
    patterns = load_patterns()
    if not patterns:
        return 0  # No patterns = no enforcement

    # Route to appropriate checker
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        action, reason = check_bash_command(command, patterns)
    elif tool_name in ("Edit", "Write"):
        file_path = tool_input.get("file_path", "")
        action, reason = check_file_tool(tool_name, file_path, patterns)
    elif tool_name == "Read":
        file_path = tool_input.get("file_path", "")
        # Check zero-access paths for Read
        action, reason = check_path_patterns(file_path, patterns)
        if not action:
            action, reason = "allow", None
    else:
        return 0  # Unknown tool, allow

    # Handle decision
    if action == "block":
        print(color(f"BLOCKED", "red"), reason, file=sys.stderr)
        return 2  # Exit 2 = blocking error
    elif action == "ask":
        output_ask_response(reason or "Requires confirmation")
        return 0
    else:
        return 0  # Allow


if __name__ == "__main__":
    sys.exit(main())
