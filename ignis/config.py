"""SilkCircuit desktop widgets for COSMIC — powered by Ignis."""

import os

from ignis.app import IgnisApp

from ignis import widgets

from modules.clock import clock_widget
from modules.media import media_widget
from modules.sysmon import sysmon_widget
from modules.weather import weather_widget

app = IgnisApp.get_default()

# Load SilkCircuit stylesheet (apply_css handles SCSS compilation)
style_path = os.path.join(os.path.dirname(__file__), "style.scss")
if os.path.exists(style_path):
    app.apply_css(style_path)


# ── Top-right: Clock + Weather ──────────────────────────────────
widgets.Window(
    namespace="sc-clock-weather",
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
    anchor=["bottom", "left"],
    exclusivity="normal",
    layer="bottom",
    margin_bottom=20,
    margin_left=20,
    child=media_widget(),
)
