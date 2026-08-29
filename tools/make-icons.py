#!/usr/bin/env python3
"""Generate the PWA icons (an "M" with a down arrow, white on the app's blue).

Drawn with a signed-distance field so the edges are antialiased without
supersampling, and written with a minimal PNG encoder — no image libraries,
so this runs anywhere Python does.

    python3 tools/make-icons.py
"""
import struct
import zlib
from pathlib import Path

BG = (0x25, 0x63, 0xEB)
FG = (0xFF, 0xFF, 0xFF)
OUT = Path(__file__).resolve().parent.parent / "pwa"


def seg_distance(px, py, x1, y1, x2, y2):
    """Distance from a point to a line segment."""
    dx, dy = x2 - x1, y2 - y1
    if dx == 0 and dy == 0:
        return ((px - x1) ** 2 + (py - y1) ** 2) ** 0.5
    t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = 0.0 if t < 0 else (1.0 if t > 1 else t)
    return ((px - (x1 + t * dx)) ** 2 + (py - (y1 + t * dy)) ** 2) ** 0.5


def rounded_rect_distance(px, py, w, h, r):
    """Negative inside the rounded rectangle, positive outside."""
    qx = abs(px - w / 2) - (w / 2 - r)
    qy = abs(py - h / 2) - (h / 2 - r)
    ox, oy = max(qx, 0.0), max(qy, 0.0)
    return (ox * ox + oy * oy) ** 0.5 + min(max(qx, qy), 0.0) - r


def glyph_strokes(size, scale):
    """The M and the arrow, as (x1, y1, x2, y2, half_width) in pixels."""
    c = size / 2
    S = size * scale

    def px(fx, fy):
        return c + (fx - 0.5) * S, c + (fy - 0.5) * S

    mt, at = 0.078 * S / 2, 0.060 * S / 2   # half stroke widths

    m_top, m_bot = 0.34, 0.66
    m_l, m_mid, m_r = 0.17, 0.335, 0.50
    a_x, a_top, a_bot = 0.715, 0.325, 0.675
    barb = 0.082

    pts = [
        (px(m_l, m_bot), px(m_l, m_top), mt),          # left stem
        (px(m_l, m_top), px(m_mid, 0.52), mt),         # left diagonal
        (px(m_mid, 0.52), px(m_r, m_top), mt),         # right diagonal
        (px(m_r, m_top), px(m_r, m_bot), mt),          # right stem
        (px(a_x, a_top), px(a_x, a_bot), at),          # arrow stem
        (px(a_x - barb, a_bot - 0.10), px(a_x, a_bot), at),
        (px(a_x + barb, a_bot - 0.10), px(a_x, a_bot), at),
    ]
    return [(p1[0], p1[1], p2[0], p2[1], hw) for p1, p2, hw in pts]


def render(size, maskable=False):
    radius = 0.0 if maskable else size * 0.22
    strokes = glyph_strokes(size, 0.70 if maskable else 1.0)
    px = bytearray(size * size * 4)

    for y in range(size):
        fy = y + 0.5
        row = y * size * 4
        for x in range(size):
            fx = x + 0.5
            bg_a = 1.0 - min(max(rounded_rect_distance(fx, fy, size, size, radius) + 0.5, 0.0), 1.0)
            if bg_a <= 0.0:
                continue
            d = min(seg_distance(fx, fy, *s[:4]) - s[4] for s in strokes)
            fg_a = 1.0 - min(max(d + 0.5, 0.0), 1.0)
            r = BG[0] + (FG[0] - BG[0]) * fg_a
            g = BG[1] + (FG[1] - BG[1]) * fg_a
            b = BG[2] + (FG[2] - BG[2]) * fg_a
            i = row + x * 4
            px[i] = int(r + 0.5)
            px[i + 1] = int(g + 0.5)
            px[i + 2] = int(b + 0.5)
            px[i + 3] = int(bg_a * 255 + 0.5)
    return bytes(px)


def write_png(path, size, rgba):
    stride = size * 4
    raw = b"".join(b"\x00" + rgba[y * stride:(y + 1) * stride] for y in range(size))

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data +
                struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)
    print(f"{path.name}: {size}x{size}, {len(png):,} bytes")


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    for size in (192, 512):
        write_png(OUT / f"icon-{size}.png", size, render(size))
    write_png(OUT / "icon-maskable-512.png", 512, render(512, maskable=True))
