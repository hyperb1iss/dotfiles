"""MPRIS media player desktop widget — adaptive album art colors."""

import threading

from gi.repository import Gdk, GLib, Gtk
from ignis import widgets
from ignis.services.mpris import MprisPlayer, MprisService

from modules.colors import AlbumPalette, extract

mpris = MprisService.get_default()
_player_id = 0


def _player_widget(player: MprisPlayer) -> widgets.Box:
    """Single player display with colors that adapt to album art."""
    global _player_id
    cls_id = f"sc-dyn-{_player_id}"
    _player_id += 1

    # Per-player CSS provider for dynamic palette
    provider = Gtk.CssProvider()
    display = Gdk.Display.get_default()
    Gtk.StyleContext.add_provider_for_display(
        display, provider, Gtk.STYLE_PROVIDER_PRIORITY_USER
    )
    provider.load_from_string(AlbumPalette.default().css(cls_id))

    # Version counter prevents stale extractions from overwriting newer ones
    version = [0]

    def _apply_colors(art_url: str):
        version[0] += 1
        ver = version[0]

        def _extract():
            palette = extract(art_url)
            GLib.idle_add(lambda: ver == version[0] and provider.load_from_string(palette.css(cls_id)))

        threading.Thread(target=_extract, daemon=True).start()

    def _on_art_changed(*_args):
        if player.art_url:
            _apply_colors(player.art_url)
        else:
            provider.load_from_string(AlbumPalette.default().css(cls_id))

    player.connect("notify::art-url", _on_art_changed)

    def _on_closed(*_args):
        Gtk.StyleContext.remove_provider_for_display(display, provider)
        box.unparent()

    box = widgets.Box(
        css_classes=["sc-media-player", cls_id],
        spacing=14,
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

    player.connect("closed", _on_closed)

    # Extract colors for current art (if any)
    if player.art_url:
        _apply_colors(player.art_url)

    return box


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
