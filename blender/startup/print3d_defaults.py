"""
3D Print Scene Defaults — auto-applies metric/mm units to new files.

Installed to: ~/.config/blender/5.0/scripts/startup/
Runs automatically when Blender creates a new default scene.
"""

bl_info = {
    "name": "3D Print Scene Defaults",
    "author": "dotfiles",
    "version": (1, 0, 0),
    "blender": (5, 0, 0),
    "category": "Scene",
    "description": "Sets metric/mm units and print-friendly defaults for new scenes",
}

import bpy
from bpy.app.handlers import persistent


@persistent
def set_print_defaults(_):
    """Apply 3D printing defaults when a new factory scene is loaded."""
    scene = bpy.context.scene

    # Only apply to untouched scenes (no user modifications yet)
    if scene.unit_settings.system == "METRIC" and scene.unit_settings.length_unit == "MILLIMETERS":
        return  # Already configured

    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 0.001
    scene.unit_settings.length_unit = "MILLIMETERS"


def register():
    bpy.app.handlers.load_factory_startup_post.append(set_print_defaults)


def unregister():
    if set_print_defaults in bpy.app.handlers.load_factory_startup_post:
        bpy.app.handlers.load_factory_startup_post.remove(set_print_defaults)
