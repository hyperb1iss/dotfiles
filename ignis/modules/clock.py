"""Clock + calendar desktop widget."""

import datetime

from ignis import utils, widgets


def clock_widget() -> widgets.Box:
    """Large clock with date and expandable calendar."""
    calendar = widgets.Calendar(
        css_classes=["sc-calendar"],
        visible=False,
    )

    def toggle_calendar(button):
        calendar.visible = not calendar.visible

    return widgets.Box(
        css_classes=["sc-widget", "sc-clock"],
        vertical=True,
        spacing=4,
        child=[
            widgets.Button(
                css_classes=["sc-clock-button"],
                on_click=toggle_calendar,
                child=widgets.Box(
                    vertical=True,
                    child=[
                        # Time row — hours:minutes + seconds + AM/PM inline
                        widgets.Box(
                            halign="center",
                            child=[
                                widgets.Label(
                                    css_classes=["sc-clock-time"],
                                    label=utils.Poll(
                                        1_000,
                                        lambda self: datetime.datetime.now().strftime(
                                            "%-I:%M"
                                        ),
                                    ).bind("output"),
                                ),
                                widgets.Box(
                                    css_classes=["sc-clock-suffix"],
                                    vertical=True,
                                    valign="center",
                                    child=[
                                        widgets.Label(
                                            css_classes=["sc-clock-seconds"],
                                            label=utils.Poll(
                                                1_000,
                                                lambda self: datetime.datetime.now().strftime(
                                                    "%S"
                                                ),
                                            ).bind("output"),
                                        ),
                                        widgets.Label(
                                            css_classes=["sc-clock-ampm"],
                                            label=utils.Poll(
                                                1_000,
                                                lambda self: datetime.datetime.now().strftime(
                                                    "%p"
                                                ),
                                            ).bind("output"),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                        # Date — clean sans
                        widgets.Label(
                            css_classes=["sc-clock-date"],
                            label=utils.Poll(
                                60_000,
                                lambda self: datetime.datetime.now().strftime(
                                    "%A, %B %-d"
                                ),
                            ).bind("output"),
                        ),
                    ],
                ),
            ),
            calendar,
        ],
    )
