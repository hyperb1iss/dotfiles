"""Weather desktop widget using Open-Meteo (free, no API key)."""

import json
import os
import threading
import urllib.request

from ignis import utils, widgets

# Override in ~/.config/ignis/location.json:
# { "latitude": 47.61, "longitude": -122.33, "city": "Seattle" }
DEFAULT_LAT = 47.6062
DEFAULT_LON = -122.3321
DEFAULT_CITY = "Seattle"

# Unicode weather glyphs — no icon theme dependency
WMO_CODES = {
    0: ("Clear", "☀"),
    1: ("Mostly Clear", "🌤"),
    2: ("Partly Cloudy", "⛅"),
    3: ("Overcast", "☁"),
    45: ("Foggy", "🌫"),
    48: ("Rime Fog", "🌫"),
    51: ("Light Drizzle", "🌦"),
    53: ("Drizzle", "🌦"),
    55: ("Dense Drizzle", "🌧"),
    61: ("Light Rain", "🌦"),
    63: ("Rain", "🌧"),
    65: ("Heavy Rain", "🌧"),
    66: ("Freezing Rain", "🌨"),
    67: ("Heavy Freezing Rain", "🌨"),
    71: ("Light Snow", "❄"),
    73: ("Snow", "🌨"),
    75: ("Heavy Snow", "🌨"),
    77: ("Snow Grains", "❄"),
    80: ("Light Showers", "🌦"),
    81: ("Showers", "🌧"),
    82: ("Violent Showers", "⛈"),
    85: ("Snow Showers", "🌨"),
    86: ("Heavy Snow Showers", "🌨"),
    95: ("Thunderstorm", "⛈"),
    96: ("Thunderstorm + Hail", "⛈"),
    99: ("Severe Storm", "⛈"),
}

_EMPTY = {
    "temp": "--",
    "feels_like": "--",
    "humidity": "--",
    "wind": "--",
    "description": "",
    "glyph": "…",
    "city": "",
}


def _load_location() -> tuple[float, float, str]:
    config_path = os.path.expanduser("~/.config/ignis/location.json")
    try:
        with open(config_path) as f:
            data = json.load(f)
            return (
                data.get("latitude", DEFAULT_LAT),
                data.get("longitude", DEFAULT_LON),
                data.get("city", DEFAULT_CITY),
            )
    except (FileNotFoundError, json.JSONDecodeError):
        return DEFAULT_LAT, DEFAULT_LON, DEFAULT_CITY


def _fetch_weather_sync() -> dict:
    """Fetch weather from Open-Meteo (called from background thread)."""
    lat, lon, city = _load_location()
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relative_humidity_2m,"
        f"weather_code,wind_speed_10m,apparent_temperature"
        f"&temperature_unit=fahrenheit"
        f"&wind_speed_unit=mph"
        f"&timezone=auto"
    )
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "ignis-silkcircuit"})
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.load(resp)
            current = data["current"]
            code = current.get("weather_code", 0)
            desc, glyph = WMO_CODES.get(code, ("Unknown", "?"))
            return {
                "temp": round(current["temperature_2m"]),
                "feels_like": round(current["apparent_temperature"]),
                "humidity": current["relative_humidity_2m"],
                "wind": round(current["wind_speed_10m"]),
                "description": desc,
                "glyph": glyph,
                "city": city,
            }
    except Exception:
        return {**_EMPTY, "city": city}


def _get(w, key, fallback=""):
    return w.get(key, fallback) if isinstance(w, dict) else fallback


def _stat_column(label: str, css_value: str, poll, formatter) -> widgets.Box:
    """Single stat column: label on top, value below."""
    return widgets.Box(
        css_classes=["sc-weather-stat"],
        vertical=True,
        halign="center",
        child=[
            widgets.Label(
                css_classes=["sc-weather-stat-label"],
                label=label,
            ),
            widgets.Label(
                css_classes=["sc-weather-stat-value", css_value],
                label=poll.bind("output", formatter),
            ),
        ],
    )


def weather_widget() -> widgets.Box:
    _cache = dict(_EMPTY)
    _lock = threading.Lock()
    _first = [True]

    def _poll_weather(self) -> dict:
        if _first[0]:
            _first[0] = False
            result = _fetch_weather_sync()
            with _lock:
                _cache.update(result)
            return dict(result)

        def _bg():
            result = _fetch_weather_sync()
            with _lock:
                _cache.update(result)

        threading.Thread(target=_bg, daemon=True).start()
        with _lock:
            return dict(_cache)

    poll = utils.Poll(600_000, _poll_weather)

    return widgets.Box(
        css_classes=["sc-widget", "sc-weather"],
        vertical=True,
        spacing=4,
        child=[
            # ── Glyph — massive cinematic presence ────────────
            widgets.Label(
                css_classes=["sc-weather-glyph"],
                halign="center",
                label=poll.bind("output", lambda w: _get(w, "glyph", "☀")),
            ),
            # ── Hero temperature ──────────────────────────────
            widgets.Label(
                css_classes=["sc-weather-temp"],
                halign="center",
                label=poll.bind(
                    "output",
                    lambda w: f"{_get(w, 'temp', '--')}°",
                ),
            ),
            # ── Condition description ─────────────────────────
            widgets.Label(
                css_classes=["sc-weather-desc"],
                halign="center",
                label=poll.bind("output", lambda w: _get(w, "description", "")),
            ),
            # ── Separator ─────────────────────────────────────
            widgets.Box(css_classes=["sc-separator"]),
            # ── Stats row — feels / humidity / wind ───────────
            widgets.Box(
                css_classes=["sc-weather-stats-row"],
                halign="center",
                homogeneous=True,
                child=[
                    _stat_column(
                        "FEELS",
                        "sc-stat-cyan",
                        poll,
                        lambda w: f"{_get(w, 'feels_like', '--')}°",
                    ),
                    widgets.Box(css_classes=["sc-weather-stat-divider"]),
                    _stat_column(
                        "HUMID",
                        "sc-stat-coral",
                        poll,
                        lambda w: f"{_get(w, 'humidity', '--')}%",
                    ),
                    widgets.Box(css_classes=["sc-weather-stat-divider"]),
                    _stat_column(
                        "WIND",
                        "sc-stat-green",
                        poll,
                        lambda w: f"{_get(w, 'wind', '--')}",
                    ),
                ],
            ),
            # ── Separator ─────────────────────────────────────
            widgets.Box(css_classes=["sc-separator"]),
            # ── City ──────────────────────────────────────────
            widgets.Label(
                css_classes=["sc-weather-city"],
                halign="center",
                label=poll.bind("output", lambda w: _get(w, "city", "")),
            ),
        ],
    )
