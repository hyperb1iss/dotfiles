"""SilkCircuit desktop widgets for COSMIC — powered by Ignis."""

import os

from ignis import utils, widgets
from ignis.css_manager import CssManager, CssInfoPath

from modules.clock import clock_widget
from modules.media import media_widget
from modules.sysmon import sysmon_widget
from modules.weather import weather_widget

# Load SilkCircuit stylesheet (SCSS → CSS compilation via sass)
style_path = os.path.join(os.path.dirname(__file__), "style.scss")
if os.path.exists(style_path):
    CssManager.get_default().apply_css(
        CssInfoPath(
            name="silkcircuit",
            path=style_path,
            compiler_function=lambda path: utils.sass_compile(path=path),
        )
    )


def _primary_monitor() -> int:
    """Find the primary monitor — widest landscape display wins."""
    best, best_width = 0, 0
    for i in range(utils.get_n_monitors()):
        mon = utils.get_monitor(i)
        if mon:
            geo = mon.get_geometry()
            if geo.width > best_width:
                best, best_width = i, geo.width
    return best


PRIMARY = _primary_monitor()


# ── Top-right: Clock + Weather ──────────────────────────────────
widgets.Window(
    namespace="sc-clock-weather",
    monitor=PRIMARY,
    anchor=["top", "right"],
    exclusivity="normal",
    layer="bottom",
    margin_top=20,
    margin_right=20,
    child=widgets.Box(
        vertical=True,
        spacing=16,
        child=[
            clock_widget(),
            weather_widget(),
        ],
    ),
)


# ── Bottom-right: System Monitor ────────────────────────────────
widgets.Window(
    namespace="sc-sysmon",
    monitor=PRIMARY,
    anchor=["bottom", "right"],
    exclusivity="normal",
    layer="bottom",
    margin_bottom=20,
    margin_right=20,
    child=sysmon_widget(),
)


# ── Bottom-left: Media Player ───────────────────────────────────
widgets.Window(
    namespace="sc-media",
    monitor=PRIMARY,
    anchor=["bottom", "left"],
    exclusivity="normal",
    layer="bottom",
    margin_bottom=20,
    margin_left=20,
    child=media_widget(),
)
