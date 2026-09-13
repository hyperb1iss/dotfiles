#!/usr/bin/env python3
"""Moniker: two-word tab names for herdr, from what the agent is doing.

Herdr numbers tabs. This watches agent lifecycle events and, the first time
an agent session starts working in a pane, asks a fast model for a name no
longer than two words, then renames the tab. Unicode is welcome, emoji are
not, whimsy is encouraged.

Runs as a herdr plugin (see herdr-plugin.toml). Herdr injects
HERDR_BIN_PATH, HERDR_PLUGIN_STATE_DIR, HERDR_PANE_ID and, for events,
HERDR_PLUGIN_EVENT_JSON. Everything fails open: a naming failure never
blocks herdr, it just leaves the number.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import time
import unicodedata
from pathlib import Path

MODEL = os.environ.get("MONIKER_MODEL", "claude-haiku-4-5-20251001")
MAX_WORDS = 2
MAX_CHARS = 28
SCREEN_LINES = 60

SYSTEM_PROMPT = """You name terminal tabs for a software engineer who runs many coding agents at once.

Given a glimpse of what one agent session is doing, reply with a tab name of AT MOST TWO WORDS.

Rules:
- Two words maximum. One is fine. Never three.
- Clever, specific, a little whimsical. Puns and wordplay welcome when they fit.
- Name the actual work (the feature, the bug, the tool), never the process ("Coding", "Task", "Session", "Working").
- Unicode is fine (accents, arrows, middle dots). Emoji are forbidden.
- Title Case. No quotes, no trailing punctuation, no explanation.

Examples of the style (never reuse these, invent one for the session at hand): Theme Layer, Glow Pinned, Tab Whisperer, Atuin Rescue, Retry Storm, Lockfile Drift, Nvim Sync.

Reply with the name only."""


def log(msg: str) -> None:
    state = os.environ.get("HERDR_PLUGIN_STATE_DIR")
    if not state:
        return
    try:
        Path(state).mkdir(parents=True, exist_ok=True)
        with open(Path(state) / "moniker.log", "a", encoding="utf-8") as fh:
            fh.write(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} {msg}\n")
    except OSError:
        pass


def herdr_text(*args: str, timeout: float = 10) -> str | None:
    """Run a herdr CLI command; stdout on success, None on any failure."""
    binary = os.environ.get("HERDR_BIN_PATH") or shutil.which("herdr")
    if not binary:
        return None
    try:
        proc = subprocess.run(
            [binary, *args], capture_output=True, text=True, timeout=timeout, check=False
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if proc.returncode != 0:
        log(f"herdr {' '.join(args[:2])} failed: {proc.stderr.strip()[:200]}")
        return None
    return proc.stdout


def herdr(*args: str, timeout: float = 10) -> dict | None:
    """Run a JSON-speaking herdr command and parse its reply."""
    out = herdr_text(*args, timeout=timeout)
    if out is None:
        return None
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        return None


def find_claude() -> str | None:
    found = shutil.which("claude")
    if found:
        return found
    home = Path.home()
    for candidate in (
        "/opt/homebrew/bin/claude",
        "/usr/local/bin/claude",
        home / ".local/bin/claude",
        home / ".claude/local/claude",
    ):
        if os.access(candidate, os.X_OK):
            return str(candidate)
    return None


# --- naming -----------------------------------------------------------------


def is_emoji(ch: str) -> bool:
    cp = ord(ch)
    if ch in "‍️":
        return True
    if 0x1F000 <= cp <= 0x1FAFF or 0x2600 <= cp <= 0x27BF or 0x1F1E6 <= cp <= 0x1F1FF:
        return True
    return unicodedata.category(ch) in {"So", "Cs"}


def clean(raw: str) -> str | None:
    """Reduce a model reply to at most two emoji-free words, or None."""
    line = raw.strip().splitlines()[0] if raw.strip() else ""
    line = "".join(ch for ch in line if not is_emoji(ch))
    line = line.strip().strip("\"'`*_.:;,!").strip()
    words = [w for w in re.split(r"\s+", line) if w]
    if not words:
        return None
    name = " ".join(words[:MAX_WORDS])
    if len(name) > MAX_CHARS:
        name = name[:MAX_CHARS].rstrip()
    return name or None


def ask_claude(material: str) -> str | None:
    claude = find_claude()
    if not claude:
        log("claude not found")
        return None
    # An ANTHROPIC_API_KEY in the environment routes print mode to that key
    # and its spend cap; the subscription login is what we want here.
    env = {k: v for k, v in os.environ.items() if k != "ANTHROPIC_API_KEY"}
    cmd = [
        claude, "-p", "--no-session-persistence", "--model", MODEL,
        "--output-format", "text", "--system-prompt", SYSTEM_PROMPT, material,
    ]
    try:
        proc = subprocess.run(
            cmd, capture_output=True, text=True, timeout=40, env=env, check=False
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        log(f"claude failed: {exc}")
        return None
    if proc.returncode != 0:
        log(f"claude exit {proc.returncode}: {proc.stderr.strip()[:200]}")
        return None
    return clean(proc.stdout)


def local_fallback(agent: dict) -> str | None:
    title = (agent.get("terminal_title_stripped") or "").strip()
    if title:
        return clean(title)
    cwd = agent.get("foreground_cwd") or agent.get("cwd") or ""
    base = Path(cwd).name if cwd else ""
    return clean(base.replace("-", " ").title()) if base else None


def gather(pane_id: str, agent: dict) -> str:
    parts = []
    kind = agent.get("agent") or "unknown"
    parts.append(f"Agent: {kind}")
    cwd = agent.get("foreground_cwd") or agent.get("cwd")
    if cwd:
        parts.append(f"Project directory: {Path(cwd).name}")
    title = agent.get("terminal_title_stripped")
    if title:
        parts.append(f"Agent's own summary of the session: {title}")
    # pane read speaks plain text, not JSON.
    text = herdr_text(
        "pane", "read", pane_id, "--source", "recent-unwrapped", "--lines", str(SCREEN_LINES)
    ) or ""
    if text.strip():
        parts.append("Recent terminal output:\n" + text.strip()[-4000:])
    return "\n\n".join(parts)


def name_pane(pane_id: str, force: bool) -> None:
    info = herdr("agent", "get", pane_id)
    agent = (info or {}).get("result", {}).get("agent") or {}
    if not agent:
        log(f"{pane_id}: no agent")
        return
    tab_id = agent.get("tab_id")
    if not tab_id:
        return
    session = (agent.get("agent_session") or {}).get("value") or ""
    key = f"{pane_id}:{session}"

    state_dir = Path(os.environ.get("HERDR_PLUGIN_STATE_DIR") or Path.home() / ".cache/moniker")
    state_dir.mkdir(parents=True, exist_ok=True)
    named_file = state_dir / "named.json"
    try:
        named = json.loads(named_file.read_text())
    except (OSError, ValueError):
        named = {}
    if not force and named.get(pane_id) == key:
        return

    name = ask_claude(gather(pane_id, agent)) or local_fallback(agent)
    if not name:
        log(f"{pane_id}: nothing to name from")
        return
    if herdr_text("tab", "rename", tab_id, name) is None:
        return
    named[pane_id] = key
    try:
        named_file.write_text(json.dumps(named))
    except OSError:
        pass
    log(f"{pane_id} -> {tab_id} '{name}'")


# --- entrypoints --------------------------------------------------------------


def on_event() -> None:
    try:
        event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
    except ValueError:
        return
    if event.get("agent_status") != "working":
        return
    pane_id = event.get("pane_id") or os.environ.get("HERDR_PANE_ID")
    if pane_id:
        name_pane(pane_id, force=False)


def on_rename() -> None:
    pane_id = os.environ.get("HERDR_PANE_ID")
    if not pane_id:
        try:
            ctx = json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}")
        except ValueError:
            ctx = {}
        pane_id = (ctx.get("pane") or {}).get("pane_id") or ctx.get("pane_id")
    if pane_id:
        name_pane(pane_id, force=True)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "event"
    try:
        on_rename() if mode == "rename" else on_event()
    except Exception as exc:  # noqa: BLE001 - never block herdr
        log(f"unexpected: {exc!r}")
    sys.exit(0)
