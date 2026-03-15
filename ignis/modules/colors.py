"""Album art color extraction for adaptive media widget theming."""

import colorsys
import urllib.request
from functools import lru_cache
from urllib.parse import unquote, urlparse

try:
    from PIL import Image

    _HAS_PIL = True
except ImportError:
    _HAS_PIL = False

# SilkCircuit defaults
_PURPLE = (225, 53, 255)
_CORAL = (255, 106, 193)
_CYAN = (128, 255, 234)


def _rgb(c: tuple) -> str:
    return f"{c[0]},{c[1]},{c[2]}"


class AlbumPalette:
    """Vibrant color palette extracted from album art.

    Roles:
        primary — dominant vibrant color (borders, background tint, shadows)
        accent  — contrasting color (artist text)
        bright  — highest-energy color (play button, interactive elements)
    """

    __slots__ = ("primary", "accent", "bright")

    def __init__(self, primary: tuple, accent: tuple, bright: tuple):
        self.primary = primary
        self.accent = accent
        self.bright = bright

    @classmethod
    def default(cls) -> "AlbumPalette":
        return cls(_PURPLE, _CORAL, _CYAN)

    def css(self, cls_id: str) -> str:
        """Generate scoped CSS targeting a specific player widget."""
        p, a, b = _rgb(self.primary), _rgb(self.accent), _rgb(self.bright)
        s = f".sc-media-player.{cls_id}"
        return f"""
{s} {{
  background: linear-gradient(150deg, rgba({p},0.1) 0%, rgba(5,4,14,0.4) 100%);
  border: 1px solid rgba({p},0.18);
  box-shadow: 0 0 30px rgba({p},0.06), inset 0 1px 0 rgba({p},0.05);
}}
{s} .sc-media-art {{
  box-shadow: 0 4px 24px rgba({p},0.3);
}}
{s} .sc-media-artist {{
  color: rgb({a});
  text-shadow: 0 0 12px rgba({a},0.25);
}}
{s} .sc-media-btn-play {{
  color: rgb({b});
  text-shadow: 0 0 16px rgba({b},0.35);
}}
{s} .sc-media-btn-play:hover {{
  background-color: rgba({b},0.12);
}}
{s} .sc-media-btn:hover {{
  background-color: rgba({b},0.08);
  color: rgb({b});
}}
"""


def _vibrancy(r: int, g: int, b: int) -> float:
    """Score color vibrancy — high saturation + medium brightness wins."""
    _, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    if v < 0.15 or (v > 0.95 and s < 0.1):
        return 0.0
    return s * (0.4 + 0.6 * v)


def _boost(r: int, g: int, b: int) -> tuple:
    """Ensure color is visible against dark backgrounds."""
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    v = max(v, 0.55)
    if s > 0.1:
        s = max(s, 0.4)
    r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
    return int(r2 * 255), int(g2 * 255), int(b2 * 255)


def _hue_dist(c1: tuple, c2: tuple) -> float:
    """Circular hue distance between two colors (0–0.5)."""
    h1 = colorsys.rgb_to_hsv(c1[0] / 255, c1[1] / 255, c1[2] / 255)[0]
    h2 = colorsys.rgb_to_hsv(c2[0] / 255, c2[1] / 255, c2[2] / 255)[0]
    d = abs(h1 - h2)
    return min(d, 1.0 - d)


def _resolve(art_url: str) -> str | None:
    """Resolve MPRIS art_url to a local file path."""
    if not art_url:
        return None
    parsed = urlparse(art_url)
    if parsed.scheme == "file":
        return unquote(parsed.path)
    if parsed.scheme in ("http", "https"):
        try:
            path, _ = urllib.request.urlretrieve(art_url)
            return path
        except Exception:
            return None
    return art_url


@lru_cache(maxsize=64)
def extract(art_url: str) -> AlbumPalette:
    """Extract a vibrant palette from album art. Cached by URL."""
    if not _HAS_PIL or not art_url:
        return AlbumPalette.default()

    path = _resolve(art_url)
    if not path:
        return AlbumPalette.default()

    try:
        img = Image.open(path).convert("RGB").resize((64, 64), Image.LANCZOS)
        quantized = img.quantize(colors=12, method=Image.Quantize.MEDIANCUT)
        pal = quantized.getpalette()
        counts = sorted(quantized.getcolors(), reverse=True)

        # Score candidates by vibrancy weighted by pixel count
        scored = []
        for count, idx in counts:
            r, g, b = pal[idx * 3 : idx * 3 + 3]
            v = _vibrancy(r, g, b)
            if v > 0.08:
                scored.append((v * count**0.25, (r, g, b)))
        scored.sort(reverse=True)

        if not scored:
            return AlbumPalette.default()

        primary = _boost(*scored[0][1])

        # Accent: most hue-contrasting vibrant color
        accent = primary
        for _, c in scored[1:]:
            if _hue_dist(primary, c) > 0.08:
                accent = _boost(*c)
                break

        # Bright: distinct third color, or lighter variant of primary
        bright = primary
        for _, c in scored:
            boosted = _boost(*c)
            if boosted != primary and boosted != accent:
                bright = boosted
                break

        return AlbumPalette(primary, accent, bright)
    except Exception:
        return AlbumPalette.default()
