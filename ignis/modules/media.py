"""MPRIS media player desktop widget."""

from ignis.services.mpris import MprisPlayer, MprisService
from ignis import widgets

mpris = MprisService.get_default()


def _player_widget(player: MprisPlayer) -> widgets.Box:
    """Single player display with art, info, and controls."""
    return widgets.Box(
        css_classes=["sc-media-player"],
        spacing=14,
        setup=lambda self: player.connect("closed", lambda x: self.unparent()),
        child=[
            # Album art
            widgets.Picture(
                css_classes=["sc-media-art"],
                image=player.bind("art_url"),
                width=72,
                height=72,
                content_fit="cover",
            ),
            # Track info + controls
            widgets.Box(
                vertical=True,
                hexpand=True,
                spacing=6,
                child=[
                    widgets.Label(
                        css_classes=["sc-media-title"],
                        label=player.bind("title"),
                        ellipsize="end",
                        max_width_chars=28,
                        halign="start",
                    ),
                    widgets.Label(
                        css_classes=["sc-media-artist"],
                        label=player.bind("artist"),
                        ellipsize="end",
                        max_width_chars=28,
                        halign="start",
                    ),
                    # Transport controls
                    widgets.Box(
                        css_classes=["sc-media-controls"],
                        spacing=6,
                        child=[
                            widgets.Button(
                                css_classes=["sc-media-btn"],
                                child=widgets.Label(label="⏮"),
                                on_click=lambda x: player.previous(),
                            ),
                            widgets.Button(
                                css_classes=["sc-media-btn", "sc-media-btn-play"],
                                child=widgets.Label(
                                    label=player.bind(
                                        "playback_status",
                                        lambda s: "⏸" if s == "Playing" else "▶",
                                    ),
                                ),
                                on_click=lambda x: player.play_pause(),
                            ),
                            widgets.Button(
                                css_classes=["sc-media-btn"],
                                child=widgets.Label(label="⏭"),
                                on_click=lambda x: player.next(),
                            ),
                        ],
                    ),
                ],
            ),
        ],
    )


def media_widget() -> widgets.Box:
    """Media player widget — shows active MPRIS players."""
    container = widgets.Box(
        css_classes=["sc-widget", "sc-media"],
        vertical=True,
        spacing=10,
        child=[
            widgets.Label(
                css_classes=["sc-widget-title"],
                label="NOW PLAYING",
                halign="start",
            ),
        ],
        setup=lambda self: mpris.connect(
            "player-added",
            lambda x, player: self.append(_player_widget(player)),
        ),
    )

    for player in mpris.players:
        container.append(_player_widget(player))

    return container
