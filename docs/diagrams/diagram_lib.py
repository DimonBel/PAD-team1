"""A small drawing model that writes the same diagram as an Excalidraw scene and as an SVG.

Every shape is added once to a `Diagram`. `to_excalidraw()` gives a scene that opens and edits at
https://excalidraw.com (File > Open), and `to_svg()` gives a clean vector for the README. The PNGs
are rendered from the SVGs by build.py.
"""

from __future__ import annotations

import hashlib
import json
import math
from xml.sax.saxutils import escape

FONT = "Helvetica Neue, Helvetica, Arial, sans-serif"
MONO = "SFMono-Regular, Menlo, Consolas, monospace"
LINE_HEIGHT = 1.25

INK = "#1e1e1e"
MUTED = "#495057"
FAINT = "#868e96"

# (fill, stroke) per kind of component. The legend of every diagram uses the same keys.
KINDS = {
    "client": ("#f1f3f5", "#495057"),
    "edge": ("#fff3bf", "#e67700"),
    "broker": ("#e5dbff", "#5f3dc4"),
    "discovery": ("#d3f9d8", "#2b8a3e"),
    "service": ("#d0ebff", "#1864ab"),
    "db": ("#c5f6fa", "#0b7285"),
    "cache": ("#ffe3e3", "#c92a2a"),
    "analytics": ("#f3d9fa", "#862e9c"),
    "observe": ("#ffe8cc", "#d9480f"),
    "infra": ("#e9ecef", "#343a40"),
    "note": ("#ffffff", "#adb5bd"),
    "ok": ("#d3f9d8", "#2b8a3e"),
    "warn": ("#fff3bf", "#e67700"),
    "bad": ("#ffe3e3", "#c92a2a"),
}

ARROWS = {
    "request": "#343a40",
    "ws": "#e03131",
    "discovery": "#2f9e44",
    "data": "#862e9c",
    "infra": "#868e96",
    "cache": "#c92a2a",
    "db": "#0b7285",
    "broker": "#5f3dc4",
    "observe": "#d9480f",
}


def text_width(s: str, size: float, bold: bool = False, mono: bool = False) -> float:
    """Approximate rendered width of one line in Helvetica (or a monospace font)."""
    if mono:
        return len(s) * size * 0.61
    w = 0.0
    for ch in s:
        if ch in "ijl.,:;'|!·":
            w += 0.25
        elif ch in "ftrI()[]{}/- ":
            w += 0.32
        elif ch in "mwMW%@":
            w += 0.86
        elif ch.isupper() or ch in "→←↔≈≤≥×":
            w += 0.68
        elif ch.isdigit():
            w += 0.56
        else:
            w += 0.55
    return w * size * (1.07 if bold else 1.0)


class Diagram:
    def __init__(self, name: str, width: int, height: int, title: str, subtitle: str = ""):
        self.name = name
        self.width = width
        self.height = height
        self.els: list[dict] = []
        self._n = 0
        self._groups = 0
        if title:
            self.text(40, 28, title, size=30, bold=True)
        if subtitle:
            self.text(40, 72, subtitle, size=15, color=MUTED)

    # ------------------------------------------------------------------ primitives

    def _id(self, prefix: str) -> str:
        self._n += 1
        return f"{self.name[:12]}-{prefix}-{self._n}"

    def group(self) -> str:
        self._groups += 1
        return f"{self.name[:12]}-g{self._groups}"

    def rect(self, x, y, w, h, fill="#ffffff", stroke=INK, sw=2.0, dashed=False, radius=10,
             groups=None, opacity=100):
        el = dict(kind="rect", id=self._id("r"), x=x, y=y, w=w, h=h, fill=fill, stroke=stroke,
                  sw=sw, dashed=dashed, radius=radius, groups=groups or [], opacity=opacity)
        self.els.append(el)
        return el["id"]

    def ellipse(self, x, y, w, h, fill="#ffffff", stroke=INK, sw=2.0, dashed=False, groups=None):
        el = dict(kind="ellipse", id=self._id("e"), x=x, y=y, w=w, h=h, fill=fill, stroke=stroke,
                  sw=sw, dashed=dashed, groups=groups or [])
        self.els.append(el)
        return el["id"]

    def text(self, x, y, s, size=14, color=INK, align="left", bold=False, mono=False, groups=None):
        """`x` is the left edge for align=left, the centre for center, the right edge for right.
        `y` is the top of the first line."""
        lines = s.split("\n")
        w = max(text_width(l, size, bold, mono) for l in lines)
        h = len(lines) * size * LINE_HEIGHT
        left = x if align == "left" else x - w / 2 if align == "center" else x - w
        el = dict(kind="text", id=self._id("t"), x=left, y=y, w=w, h=h, text=s, size=size,
                  color=color, align=align, bold=bold, mono=mono, anchor_x=x, groups=groups or [])
        self.els.append(el)
        return el["id"]

    def arrow(self, pts, color=ARROWS["request"], sw=2.0, dashed=False, end=True, start=False,
              dotted=False, groups=None):
        el = dict(kind="arrow", id=self._id("a"), pts=[tuple(p) for p in pts], color=color, sw=sw,
                  dashed=dashed, dotted=dotted, end=end, start=start, groups=groups or [])
        self.els.append(el)
        return el["id"]

    def line(self, pts, color=FAINT, sw=1.5, dashed=False, groups=None):
        return self.arrow(pts, color=color, sw=sw, dashed=dashed, end=False, start=False,
                          groups=groups)

    # ------------------------------------------------------------------ composites

    def box(self, x, y, w, h, kind="service", title="", body=(), title_size=17, body_size=13,
            valign="center", align="center", dashed=False, sw=2.0, fill=None, stroke=None,
            badge=None, mono_body=False, stack=0, radius=10):
        """A component: a rounded rectangle with a bold title and lines of detail, grouped so they
        move together in Excalidraw. `stack` draws that many offset copies behind it (replicas)."""
        f, s = KINDS[kind]
        f, s = fill or f, stroke or s
        g = self.group()
        for i in range(stack, 0, -1):
            self.rect(x + 7 * i, y - 7 * i, w, h, fill=f, stroke=s, sw=1.5, groups=[g],
                      radius=radius)
        self.rect(x, y, w, h, fill=f, stroke=s, sw=sw, dashed=dashed, groups=[g], radius=radius)
        body = list(body)
        th = title_size * LINE_HEIGHT if title else 0
        bh = len(body) * body_size * LINE_HEIGHT
        gap = 6 if title and body else 0
        total = th + gap + bh
        top = y + (h - total) / 2 if valign == "center" else y + 12
        if badge:
            self.pill(x + w - 10, y - 11, badge, kind="bad" if badge.startswith("Lab") else kind,
                      align="right", groups=[g])
        tx = x + w / 2 if align == "center" else x + 14
        if title:
            self.text(tx, top, title, size=title_size, bold=True, align=align, groups=[g])
        if body:
            self.text(tx, top + th + gap, "\n".join(body), size=body_size, color=MUTED, align=align,
                      mono=mono_body, groups=[g])
        return g

    def pill(self, x, y, label, kind="note", align="left", size=11, groups=None):
        f, s = KINDS[kind]
        w = text_width(label, size, bold=True) + 16
        h = size + 10
        left = x if align == "left" else x - w if align == "right" else x - w / 2
        self.rect(left, y, w, h, fill=f, stroke=s, sw=1.5, radius=h / 2, groups=groups)
        self.text(left + w / 2, y + 5, label, size=size, bold=True, color=s, align="center",
                  groups=groups)

    def zone(self, x, y, w, h, label, kind="note", label_align="left", sub=None):
        """A dashed area that groups related components, with its label on the top edge."""
        f, s = KINDS[kind]
        self.rect(x, y, w, h, fill="#fcfcfd" if kind == "note" else f, stroke=s, sw=1.5,
                  dashed=True, radius=14, opacity=100 if kind == "note" else 35)
        lx = x + 16 if label_align == "left" else x + w - 16
        self.text(lx, y + 10, label, size=13, bold=True, color=s if kind != "note" else MUTED,
                  align=label_align)
        if sub:
            self.text(lx, y + 28, sub, size=12, color=FAINT, align=label_align)

    def label(self, x, y, s, size=12, color=MUTED, align="center", bold=False, bg=True):
        """Text on top of a white patch, so it stays readable where it crosses a line."""
        lines = s.split("\n")
        w = max(text_width(l, size, bold) for l in lines) + 10
        h = len(lines) * size * LINE_HEIGHT + 4
        left = x - w / 2 if align == "center" else x - 5 if align == "left" else x - w + 5
        g = self.group()
        if bg:
            self.rect(left, y - 2, w, h, fill="#ffffff", stroke="transparent", sw=0, radius=4,
                      groups=[g])
        self.text(x, y, s, size=size, color=color, align=align, bold=bold, groups=[g])

    def legend(self, x, y, items, title="Legend", cols=None, col_w=330):
        """items: ("box", kind, text) | ("arrow", color, dashed, text) | ("stack", kind, text)."""
        cols = cols or len(items)
        rows = math.ceil(len(items) / cols)
        w = cols * col_w + 20
        h = rows * 30 + 44
        self.rect(x, y, w, h, fill="#ffffff", stroke="#dee2e6", sw=1.5, radius=10)
        self.text(x + 14, y + 10, title, size=13, bold=True, color=MUTED)
        for i, it in enumerate(items):
            cx = x + 14 + (i % cols) * col_w
            cy = y + 36 + (i // cols) * 30
            if it[0] == "box":
                f, s = KINDS[it[1]]
                self.rect(cx, cy, 34, 20, fill=f, stroke=s, sw=1.5, radius=5)
                label = it[2]
            elif it[0] == "stack":
                f, s = KINDS[it[1]]
                for k in (2, 1):
                    self.rect(cx + 4 * k, cy - 4 * k + 4, 30, 18, fill=f, stroke=s, sw=1, radius=4)
                self.rect(cx, cy + 4, 30, 18, fill=f, stroke=s, sw=1.5, radius=4)
                label = it[2]
            else:
                self.arrow([(cx, cy + 10), (cx + 36, cy + 10)], color=it[1], dashed=it[2], sw=2)
                label = it[3]
            self.text(cx + 46, cy + 2, label, size=13, color=INK)

    def footer(self, s):
        self.text(40, self.height - 30, s, size=11, color=FAINT)

    # ------------------------------------------------------------------ Excalidraw

    def to_excalidraw(self) -> dict:
        out = []
        for i, el in enumerate(self.els):
            seed = int(hashlib.md5(el["id"].encode()).hexdigest()[:7], 16)
            base = dict(id=el["id"], angle=0, groupIds=el["groups"], frameId=None, seed=seed,
                        version=1, versionNonce=seed ^ 0x5F5E1, isDeleted=False, boundElements=None,
                        updated=1, link=None, locked=False, roughness=0, opacity=100)
            k = el["kind"]
            if k in ("rect", "ellipse"):
                base.update(
                    type="rectangle" if k == "rect" else "ellipse",
                    x=el["x"], y=el["y"], width=el["w"], height=el["h"],
                    strokeColor=el["stroke"], backgroundColor=el["fill"], fillStyle="solid",
                    strokeWidth=max(el["sw"], 1) if el["stroke"] != "transparent" else 1,
                    strokeStyle="dashed" if el["dashed"] else "solid",
                    roundness={"type": 3, "value": el.get("radius", 10)}
                    if k == "rect" and el.get("radius") else None,
                    opacity=el.get("opacity", 100),
                )
            elif k == "text":
                base.update(
                    type="text", x=el["x"], y=el["y"], width=el["w"], height=el["h"],
                    strokeColor=el["color"], backgroundColor="transparent", fillStyle="solid",
                    strokeWidth=1, strokeStyle="solid", roundness=None, text=el["text"],
                    originalText=el["text"], fontSize=el["size"], fontFamily=3 if el["mono"] else 2,
                    textAlign=el["align"], verticalAlign="top", containerId=None, autoResize=True,
                    lineHeight=LINE_HEIGHT,
                )
            else:  # arrow / line
                (x0, y0) = el["pts"][0]
                rel = [[px - x0, py - y0] for px, py in el["pts"]]
                xs = [p[0] for p in rel]
                ys = [p[1] for p in rel]
                is_arrow = el["end"] or el["start"]
                base.update(
                    type="arrow" if is_arrow else "line", x=x0, y=y0,
                    width=max(xs) - min(xs), height=max(ys) - min(ys), points=rel,
                    strokeColor=el["color"], backgroundColor="transparent", fillStyle="solid",
                    strokeWidth=el["sw"],
                    strokeStyle="dotted" if el["dotted"] else "dashed" if el["dashed"] else "solid",
                    roundness=None, lastCommittedPoint=None, startBinding=None, endBinding=None,
                    startArrowhead="triangle" if el["start"] else None,
                    endArrowhead="triangle" if el["end"] else None,
                )
                if is_arrow:
                    base["elbowed"] = False
            out.append(base)
        return {
            "type": "excalidraw",
            "version": 2,
            "source": "https://excalidraw.com",
            "elements": out,
            "appState": {"gridSize": 20, "gridStep": 5, "viewBackgroundColor": "#ffffff"},
            "files": {},
        }

    # ------------------------------------------------------------------ SVG

    def to_svg(self, square: bool = False) -> str:
        """`square=True` centres the drawing on a square canvas, which is what the PNG renderer
        (Quick Look) handles predictably; build.py crops the square back afterwards."""
        svg = self._svg()
        if not square:
            return svg
        side = max(self.width, self.height)
        ox, oy = (side - self.width) / 2, (side - self.height) / 2
        inner = svg.split(">", 1)[1].rsplit("</svg>", 1)[0]
        return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{side}" height="{side}" '
                f'viewBox="0 0 {side} {side}" font-family="{FONT}"><rect width="{side}" '
                f'height="{side}" fill="#ffffff"/><g transform="translate({ox},{oy})">{inner}</g></svg>')

    def _svg(self) -> str:
        colors = sorted({el["color"] for el in self.els if el["kind"] == "arrow"})
        defs = []
        for c in colors:
            mid = "m" + c.lstrip("#")
            defs.append(
                f'<marker id="{mid}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="13" '
                f'markerHeight="13" orient="auto-start-reverse" markerUnits="userSpaceOnUse">'
                f'<path d="M0,0.5 L10,5 L0,9.5 z" fill="{c}"/></marker>'
            )
        parts = [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.width}" height="{self.height}" '
            f'viewBox="0 0 {self.width} {self.height}" font-family="{FONT}">',
            f"<defs>{''.join(defs)}</defs>",
            f'<rect width="{self.width}" height="{self.height}" fill="#ffffff"/>',
        ]
        for el in self.els:
            k = el["kind"]
            if k == "rect":
                stroke = "none" if el["stroke"] == "transparent" else el["stroke"]
                dash = ' stroke-dasharray="8 6"' if el["dashed"] else ""
                op = el.get("opacity", 100)
                fill_op = f' fill-opacity="{op / 100:.2f}"' if op < 100 else ""
                r = min(el["radius"], el["h"] / 2, el["w"] / 2)
                parts.append(
                    f'<rect x="{el["x"]:.1f}" y="{el["y"]:.1f}" width="{el["w"]:.1f}" '
                    f'height="{el["h"]:.1f}" rx="{r:.1f}" fill="{el["fill"]}"{fill_op} '
                    f'stroke="{stroke}" stroke-width="{el["sw"]}"{dash}/>'
                )
            elif k == "ellipse":
                dash = ' stroke-dasharray="8 6"' if el["dashed"] else ""
                parts.append(
                    f'<ellipse cx="{el["x"] + el["w"] / 2:.1f}" cy="{el["y"] + el["h"] / 2:.1f}" '
                    f'rx="{el["w"] / 2:.1f}" ry="{el["h"] / 2:.1f}" fill="{el["fill"]}" '
                    f'stroke="{el["stroke"]}" stroke-width="{el["sw"]}"{dash}/>'
                )
            elif k == "text":
                anchor = {"left": "start", "center": "middle", "right": "end"}[el["align"]]
                weight = ' font-weight="700"' if el["bold"] else ""
                fam = f' font-family="{MONO}"' if el["mono"] else ""
                tspans = []
                for i, line in enumerate(el["text"].split("\n")):
                    ty = el["y"] + el["size"] * 0.93 + i * el["size"] * LINE_HEIGHT
                    tspans.append(
                        f'<tspan x="{el["anchor_x"]:.1f}" y="{ty:.1f}">{escape(line)}</tspan>'
                    )
                parts.append(
                    f'<text xml:space="preserve" style="white-space:pre" font-size="{el["size"]}" '
                    f'fill="{el["color"]}" text-anchor="{anchor}"{weight}{fam}>{"".join(tspans)}</text>'
                )
            else:
                d = "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in el["pts"])
                dash = (' stroke-dasharray="2 5" stroke-linecap="round"' if el["dotted"]
                        else ' stroke-dasharray="9 6"' if el["dashed"] else "")
                mid = "m" + el["color"].lstrip("#")
                me = f' marker-end="url(#{mid})"' if el["end"] else ""
                ms = f' marker-start="url(#{mid})"' if el["start"] else ""
                parts.append(
                    f'<path d="{d}" fill="none" stroke="{el["color"]}" stroke-width="{el["sw"]}" '
                    f'stroke-linejoin="round"{dash}{me}{ms}/>'
                )
        parts.append("</svg>")
        return "\n".join(parts)

    def write(self, folder):
        (folder / f"{self.name}.excalidraw").write_text(
            json.dumps(self.to_excalidraw(), indent=1), encoding="utf-8")
        (folder / f"{self.name}.svg").write_text(self.to_svg(), encoding="utf-8")
