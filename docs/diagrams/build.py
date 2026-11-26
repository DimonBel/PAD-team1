#!/usr/bin/env python3
"""Builds the platform's architecture diagrams.

    python3 docs/diagrams/build.py            # .excalidraw + .svg + .png for every diagram
    python3 docs/diagrams/build.py --no-png   # skip the PNGs (they need macOS Quick Look)

Each diagram is written three times into docs/diagrams/:
- <name>.excalidraw: editable; open it at https://excalidraw.com (File > Open) or in the VS Code
  Excalidraw extension;
- <name>.svg: vector, used by the README;
- <name>.png: 2x raster, for slides and anything that can't show SVG.

Edit the diagrams here, not in the exported files, so the three formats stay the same.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from diagrams_content import ALL  # noqa: E402

HERE = Path(__file__).resolve().parent


def render_png(d, png: Path, scale: int = 2) -> bool:
    """Renders the diagram with macOS Quick Look (WebKit). Quick Look always makes a square
    thumbnail, so the drawing is centred on a square canvas first and the square is then
    cropped around its centre back to the drawing's own size."""
    if not shutil.which("qlmanage") or not shutil.which("sips"):
        return False
    side = max(d.width, d.height) * scale
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / f"{d.name}.svg"
        src.write_text(d.to_svg(square=True), encoding="utf-8")
        subprocess.run(["qlmanage", "-t", "-s", str(side), "-o", tmp, str(src)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        out = Path(tmp) / f"{src.name}.png"
        if not out.exists():
            return False
        subprocess.run(["sips", "--cropToHeightWidth", str(d.height * scale), str(d.width * scale),
                        str(out), "--out", str(png)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return True


def main() -> None:
    want_png = "--no-png" not in sys.argv
    only = [a for a in sys.argv[1:] if not a.startswith("--")]
    for make in ALL:
        d = make()
        if only and d.name not in only:
            continue
        d.write(HERE)
        line = f"{d.name}: .excalidraw .svg"
        if want_png:
            if render_png(d, HERE / f"{d.name}.png"):
                line += " .png"
            else:
                line += " (no PNG: needs macOS qlmanage + sips)"
        print(line)


if __name__ == "__main__":
    main()
