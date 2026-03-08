"""System monitoring desktop widget — CPU, RAM, disk, GPU, temps, network."""

import subprocess
import time

import psutil

from ignis import utils, widgets


# ── Stateful network tracker ────────────────────────────────────
class _NetTracker:
    def __init__(self):
        c = psutil.net_io_counters()
        self._prev_sent = c.bytes_sent
        self._prev_recv = c.bytes_recv
        self._prev_time = time.monotonic()

    def rates(self) -> tuple[float, float]:
        c = psutil.net_io_counters()
        now = time.monotonic()
        dt = now - self._prev_time
        if dt < 0.1:
            return 0.0, 0.0
        up = (c.bytes_sent - self._prev_sent) / dt
        down = (c.bytes_recv - self._prev_recv) / dt
        self._prev_sent = c.bytes_sent
        self._prev_recv = c.bytes_recv
        self._prev_time = now
        return up, down


_net = _NetTracker()


def _format_rate(b: float) -> str:
    if b >= 1024**2:
        return f"{b / 1024**2:.1f} MB/s"
    elif b >= 1024:
        return f"{b / 1024:.0f} KB/s"
    return f"{b:.0f} B/s"


# ── CPU (single poll, bind text + bar from same sample) ─────────
def _cpu_sample(self) -> float:
    return psutil.cpu_percent(interval=None)


def _cpu_freq(self) -> str:
    freq = psutil.cpu_freq()
    return f"{freq.current / 1000:.1f} GHz" if freq else "--"


def _load_avg(self) -> str:
    load = psutil.getloadavg()
    return f"{load[0]:.1f}  {load[1]:.1f}  {load[2]:.1f}"


# ── Temperature ─────────────────────────────────────────────────
def _cpu_temp(self) -> str:
    temps = psutil.sensors_temperatures()
    if "coretemp" in temps:
        cores = [e.current for e in temps["coretemp"] if "Core" in (e.label or "")]
        if cores:
            return f"{sum(cores) / len(cores):.0f}"
    if "k10temp" in temps:
        for entry in temps["k10temp"]:
            if entry.label in ("Tdie", "Tccd1"):
                return f"{entry.current:.0f}"
        if temps["k10temp"]:
            return f"{temps['k10temp'][0].current:.0f}"
    for name in ("zenpower", "cpu_thermal"):
        if name in temps and temps[name]:
            return f"{temps[name][0].current:.0f}"
    return "--"


# ── Memory ──────────────────────────────────────────────────────
def _ram_info(self) -> str:
    mem = psutil.virtual_memory()
    return f"{mem.used / 1024**3:.1f} / {mem.total / 1024**3:.0f} GB"


def _ram_percent(self) -> float:
    return psutil.virtual_memory().percent / 100.0


def _swap_info(self) -> str:
    swap = psutil.swap_memory()
    if swap.total == 0:
        return "None"
    return f"{swap.used / 1024**3:.1f} / {swap.total / 1024**3:.0f} GB"


def _swap_percent(self) -> float:
    swap = psutil.swap_memory()
    return swap.percent / 100.0 if swap.total else 0.0


# ── Disk ────────────────────────────────────────────────────────
def _disk_info(self) -> str:
    disk = psutil.disk_usage("/")
    return f"{disk.used / 1024**3:.0f} / {disk.total / 1024**3:.0f} GB"


def _disk_percent(self) -> float:
    return psutil.disk_usage("/").percent / 100.0


# ── GPU (NVIDIA) ────────────────────────────────────────────────
def _gpu_stats(self) -> dict:
    try:
        r = subprocess.run(
            [
                "nvidia-smi",
                "--query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total",
                "--format=csv,noheader,nounits",
            ],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if r.returncode != 0:
            return {}
        first_line = r.stdout.strip().split("\n")[0]
        parts = [p.strip() for p in first_line.split(",")]
        if len(parts) < 5:
            return {}
        return {
            "name": parts[0].replace("NVIDIA ", "").replace("GeForce ", ""),
            "temp": parts[1],
            "util": parts[2],
            "vram_used": int(parts[3]),
            "vram_total": int(parts[4]),
        }
    except (FileNotFoundError, subprocess.TimeoutExpired, ValueError):
        return {}


def _gpu_line(self) -> str:
    stats = _gpu_stats(self)
    if not stats:
        return ""
    return f"{stats['util']}%  {stats['temp']}°C  {stats['vram_used']}/{stats['vram_total']} MB"


def _gpu_name(self) -> str:
    return _gpu_stats(self).get("name", "")


def _gpu_fraction(self) -> float:
    stats = _gpu_stats(self)
    try:
        return int(stats.get("util", 0)) / 100.0
    except (ValueError, TypeError):
        return 0.0


# ── Network + Uptime ────────────────────────────────────────────
def _net_speeds(self) -> str:
    up, down = _net.rates()
    return f"↑ {_format_rate(up)}   ↓ {_format_rate(down)}"


def _uptime(self) -> str:
    up = time.time() - psutil.boot_time()
    days = int(up // 86400)
    hours = int((up % 86400) // 3600)
    mins = int((up % 3600) // 60)
    return f"{days}d {hours}h {mins}m" if days > 0 else f"{hours}h {mins}m"


# ── Widget builders ─────────────────────────────────────────────
def _bar_row(label, value_poll, percent_poll, bar_class="sc-bar-cyan"):
    return widgets.Box(
        css_classes=["sc-stat-block"],
        vertical=True,
        spacing=4,
        child=[
            widgets.Box(
                child=[
                    widgets.Label(
                        css_classes=["sc-stat-label"],
                        label=label,
                        halign="start",
                        hexpand=True,
                    ),
                    widgets.Label(
                        css_classes=["sc-stat-value"],
                        label=value_poll.bind("output"),
                        halign="end",
                    ),
                ],
            ),
            widgets.Scale(
                css_classes=["sc-bar", bar_class],
                min=0,
                max=1,
                value=percent_poll.bind("output"),
                sensitive=False,
            ),
        ],
    )


def _info_row(label, value_poll):
    return widgets.Box(
        css_classes=["sc-info-row"],
        child=[
            widgets.Label(
                css_classes=["sc-info-label"],
                label=label,
                halign="start",
                hexpand=True,
            ),
            widgets.Label(
                css_classes=["sc-info-value"],
                label=value_poll.bind("output"),
                halign="end",
            ),
        ],
    )


def sysmon_widget() -> widgets.Box:
    cpu_poll = utils.Poll(2_000, _cpu_sample)
    cpu_freq_poll = utils.Poll(5_000, _cpu_freq)
    temp_poll = utils.Poll(5_000, _cpu_temp)
    load_poll = utils.Poll(5_000, _load_avg)
    ram_poll = utils.Poll(5_000, _ram_info)
    ram_pct = utils.Poll(5_000, _ram_percent)
    swap_poll = utils.Poll(10_000, _swap_info)
    swap_pct = utils.Poll(10_000, _swap_percent)
    disk_poll = utils.Poll(30_000, _disk_info)
    disk_pct = utils.Poll(30_000, _disk_percent)
    gpu_poll = utils.Poll(3_000, _gpu_line)
    gpu_name_poll = utils.Poll(30_000, _gpu_name)
    gpu_frac = utils.Poll(3_000, _gpu_fraction)
    net_poll = utils.Poll(2_000, _net_speeds)
    uptime_poll = utils.Poll(60_000, _uptime)

    return widgets.Box(
        css_classes=["sc-widget", "sc-sysmon"],
        vertical=True,
        spacing=10,
        child=[
            # ── Hero numbers: CPU + TEMP ────────────────────────
            widgets.Box(
                css_classes=["sc-hero-row"],
                halign="center",
                spacing=0,
                child=[
                    # CPU
                    widgets.Box(
                        css_classes=["sc-hero-block"],
                        vertical=True,
                        spacing=0,
                        child=[
                            widgets.Box(
                                halign="center",
                                child=[
                                    widgets.Label(
                                        css_classes=["sc-hero-number", "sc-glow-cyan"],
                                        label=cpu_poll.bind(
                                            "output", lambda v: f"{v:.0f}"
                                        ),
                                    ),
                                    widgets.Label(
                                        css_classes=["sc-hero-suffix", "sc-glow-cyan"],
                                        label="%",
                                    ),
                                ],
                            ),
                            widgets.Label(
                                css_classes=["sc-hero-unit"],
                                label="CPU",
                            ),
                        ],
                    ),
                    # Divider
                    widgets.Separator(css_classes=["sc-hero-divider"]),
                    # Temp
                    widgets.Box(
                        css_classes=["sc-hero-block"],
                        vertical=True,
                        spacing=0,
                        child=[
                            widgets.Label(
                                css_classes=["sc-hero-number", "sc-glow-coral"],
                                label=temp_poll.bind(
                                    "output", lambda v: f"{v}°"
                                ),
                            ),
                            widgets.Label(
                                css_classes=["sc-hero-unit"],
                                label="TEMP",
                            ),
                        ],
                    ),
                ],
            ),
            # CPU bar
            widgets.Scale(
                css_classes=["sc-bar", "sc-bar-cyan"],
                min=0,
                max=1,
                value=cpu_poll.bind("output", lambda v: v / 100.0),
                sensitive=False,
            ),
            # ── CPU details ─────────────────────────────────────
            _info_row("FREQ", cpu_freq_poll),
            _info_row("LOAD", load_poll),
            widgets.Separator(css_classes=["sc-separator"]),
            # ── GPU ─────────────────────────────────────────────
            widgets.Box(
                vertical=True,
                spacing=4,
                child=[
                    widgets.Box(
                        child=[
                            widgets.Label(
                                css_classes=["sc-stat-label"],
                                label="GPU",
                                halign="start",
                                hexpand=True,
                            ),
                            widgets.Label(
                                css_classes=["sc-info-value"],
                                label=gpu_name_poll.bind("output"),
                                halign="end",
                            ),
                        ],
                    ),
                    widgets.Scale(
                        css_classes=["sc-bar", "sc-bar-purple"],
                        min=0,
                        max=1,
                        value=gpu_frac.bind("output"),
                        sensitive=False,
                    ),
                    widgets.Label(
                        css_classes=["sc-gpu-stats"],
                        label=gpu_poll.bind("output"),
                        halign="start",
                    ),
                ],
            ),
            widgets.Separator(css_classes=["sc-separator"]),
            # ── Memory + Disk ───────────────────────────────────
            _bar_row("RAM", ram_poll, ram_pct, "sc-bar-cyan"),
            _bar_row("SWAP", swap_poll, swap_pct, "sc-bar-purple"),
            _bar_row("DISK", disk_poll, disk_pct, "sc-bar-coral"),
            widgets.Separator(css_classes=["sc-separator"]),
            # ── Network ─────────────────────────────────────────
            widgets.Box(
                vertical=True,
                spacing=2,
                child=[
                    widgets.Label(
                        css_classes=["sc-stat-label"],
                        label="NET",
                        halign="start",
                    ),
                    widgets.Label(
                        css_classes=["sc-net-value"],
                        label=net_poll.bind("output"),
                        halign="start",
                    ),
                ],
            ),
            # ── Footer ──────────────────────────────────────────
            _info_row("UP", uptime_poll),
        ],
    )
