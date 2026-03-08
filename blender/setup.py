"""
Blender 5.0 — One-time preferences setup for 3D printing workflow.

Run once:  blender --background --python blender/setup.py
"""

import subprocess
import sys
from pathlib import Path

import bpy

ELECTRIC_PURPLE = "\033[38;2;225;53;255m"
NEON_CYAN = "\033[38;2;128;255;234m"
SUCCESS_GREEN = "\033[38;2;80;250;123m"
ERROR_RED = "\033[38;2;255;99;99m"
RESET = "\033[0m"


def banner(msg):
    print(f"\n{ELECTRIC_PURPLE}{'─' * 50}")
    print(f"  {msg}")
    print(f"{'─' * 50}{RESET}\n")


def ok(msg):
    print(f"  {SUCCESS_GREEN}✓{RESET} {msg}")


def fail(msg):
    print(f"  {ERROR_RED}✗{RESET} {msg}")


def setup_preferences():
    """Configure Blender preferences for 3D printing workflow."""
    banner("Setting Blender preferences")
    prefs = bpy.context.preferences

    # Editing
    prefs.edit.undo_steps = 64
    ok("Undo steps: 64")

    # Auto-save every 3 minutes
    prefs.filepaths.auto_save_time = 3
    prefs.filepaths.use_auto_save_temporary_files = True
    ok("Auto-save: every 3 minutes")

    # Viewport
    prefs.view.show_splash = False
    ok("Splash screen: disabled")

    # Enable online access for extensions
    prefs.system.use_online_access = True
    prefs.filepaths.use_extension_online_access_handled = True
    ok("Online access: enabled")


def enable_bundled_addons():
    """Enable useful bundled addons."""
    banner("Enabling bundled addons")
    import addon_utils

    bundled = [
        ("node_wrangler", "Node Wrangler"),
    ]

    for addon_id, label in bundled:
        try:
            addon_utils.enable(addon_id, default_set=True, persistent=True)
            ok(f"{label}")
        except Exception as e:
            fail(f"{label}: {e}")


def install_extensions():
    """Install 3D printing extensions from Blender repository."""
    banner("Installing 3D printing extensions")

    # Extensions essential for 3D printing workflow
    extensions = [
        ("print3d_toolbox", "3D Print Toolbox — mesh analysis for printability"),
        ("bool_tool", "Bool Tool — boolean operations for hard surface"),
        ("looptools", "LoopTools — advanced mesh editing"),
        ("f2", "F2 — quick face creation"),
        ("measureit", "MeasureIt — measurement tools"),
        ("ThreeMF_io", "3MF Import/Export — modern print format"),
        ("edit_mesh_tools", "Edit Mesh Tools — extra modeling tools"),
    ]

    blender = sys.argv[0]  # Path to blender binary
    if not Path(blender).exists():
        blender = "blender"

    for ext_id, label in extensions:
        try:
            result = subprocess.run(
                [blender, "--command", "extension", "install", ext_id],
                capture_output=True,
                text=True,
                timeout=60,
            )
            if result.returncode == 0:
                ok(label)
            else:
                stderr = result.stderr.strip().split("\n")[-1] if result.stderr else "unknown error"
                if "already installed" in stderr.lower():
                    ok(f"{label} (already installed)")
                else:
                    fail(f"{label}: {stderr}")
        except subprocess.TimeoutExpired:
            fail(f"{label}: timed out")
        except Exception as e:
            fail(f"{label}: {e}")


def setup_default_scene():
    """Configure the startup scene for 3D printing (metric/mm)."""
    banner("Configuring default scene for 3D printing")

    scene = bpy.context.scene

    # Metric units in millimeters
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 0.001
    scene.unit_settings.length_unit = "MILLIMETERS"
    ok("Units: metric (millimeters)")

    # Set viewport clipping for mm scale
    for area in bpy.context.screen.areas:
        if area.type == "VIEW_3D":
            for space in area.spaces:
                if space.type == "VIEW_3D":
                    space.clip_start = 0.1
                    space.clip_end = 10000
                    ok("Viewport clip: 0.1mm — 10m")
                    break

    # Save as startup file
    bpy.ops.wm.save_homefile()
    ok("Saved as startup file")


def main():
    print(f"\n{NEON_CYAN}{'═' * 50}")
    print("  Blender 3D Printing Setup")
    print(f"{'═' * 50}{RESET}")

    setup_preferences()
    enable_bundled_addons()

    # Save preferences before installing extensions
    # (extensions use a separate CLI process)
    bpy.ops.wm.save_userpref()
    ok("Preferences saved")

    setup_default_scene()
    install_extensions()

    print(f"\n{SUCCESS_GREEN}{'═' * 50}")
    print("  Setup complete!")
    print(f"{'═' * 50}{RESET}\n")


if __name__ == "__main__":
    main()
else:
    # Running inside Blender's Python
    main()
