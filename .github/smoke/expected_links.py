#!/usr/bin/env python3
"""Print the paths a set of dotbot layers is expected to produce.

The smoke tests assert against the layers themselves rather than a
checked-in list, so adding a link to base.yaml never leaves a stale
expectation file behind. Pair it with the floor check in
assert-links.sh, which keeps a derived-from-source list from silently
shrinking to nothing.

PyYAML comes from dotbot's vendored copy, so the smoke run needs
nothing installed beyond python3 itself.

Usage:
    expected_links.py --home DIR [--kind link|create] LAYER [LAYER...]
"""

import argparse
import os
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
sys.path.insert(0, os.path.join(REPO_ROOT, "dotbot", "lib", "pyyaml", "lib"))

try:
    import yaml
except ImportError:
    sys.exit("error: no PyYAML. Run `git submodule update --init --recursive` and retry.")


def link_targets(task):
    """Yield the link locations a `link` directive declares."""
    for target, source in task.items():
        if isinstance(source, dict):
            # `if:` guards run a shell test we cannot evaluate here, so the
            # entry is reported and skipped rather than asserted blindly.
            if "if" in source:
                print(f"note: skipping conditional link {target}", file=sys.stderr)
                continue
        yield target


def create_targets(task):
    """Yield the directories a `create` directive declares."""
    if isinstance(task, dict):
        return list(task.keys())
    return list(task)


def main():
    parser = argparse.ArgumentParser(description="List the paths a dotbot layer set declares")
    parser.add_argument("--home", required=True, help="HOME the paths are expanded against")
    parser.add_argument("--kind", default="link", choices=("link", "create"), help="directive to report")
    parser.add_argument("layers", nargs="+", help="dotbot layer yaml files")
    args = parser.parse_args()

    # dotbot expands `~` through the environment, so the fake-HOME runs stay
    # honest only if the expansion here reads the same variable.
    os.environ["HOME"] = args.home

    paths = []
    for layer in args.layers:
        with open(layer, encoding="utf-8") as handle:
            tasks = yaml.safe_load(handle) or []
        for task in tasks:
            for directive, body in task.items():
                if directive != args.kind:
                    continue
                found = link_targets(body) if directive == "link" else create_targets(body)
                for path in found:
                    expanded = os.path.expanduser(path)
                    if expanded not in paths:
                        paths.append(expanded)

    for path in paths:
        print(path)


if __name__ == "__main__":
    main()
