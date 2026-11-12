#!/usr/bin/env bash
# Accessibility check of the screen shown on a device, for the manual
# non-regression pass (docs/NRT.md, section 10).
#
# Dumps the current screen's accessibility tree with uiautomator and lists
# every tappable element that has no label (text or content description,
# its own or a child's: what TalkBack reads) or is smaller than 48 dp, and
# every element announced as a button that TalkBack can't activate (no
# click action: a Semantics with excludeSemantics that hides the inner tap).
#
# Usage: ./nrt_a11y_check.sh [adb-device]   (default: the only device)
# Exit code 1 when it finds a problem.

set -euo pipefail

serial=${1:-}
adb_cmd=(adb)
[[ -n "$serial" ]] && adb_cmd+=(-s "$serial")

dump=$(mktemp)
trap 'rm -f "$dump"' EXIT

"${adb_cmd[@]}" shell uiautomator dump /sdcard/nrt_a11y.xml >/dev/null
"${adb_cmd[@]}" exec-out cat /sdcard/nrt_a11y.xml >"$dump"
"${adb_cmd[@]}" shell rm -f /sdcard/nrt_a11y.xml

density=$("${adb_cmd[@]}" shell wm density | awk -F': ' '/Override/ {o=$2} /Physical/ {p=$2} END {print (o ? o : p)}' | tr -d '\r')

python3 -I - "$dump" "$density" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET

path, density = sys.argv[1], float(sys.argv[2])
scale = density / 160  # px per dp
root = ET.parse(path).getroot()
screen_h = max(int(re.findall(r"\d+", n.get("bounds", "0,0,0,0"))[3]) for n in root.iter("node"))


def label(node):
    for n in node.iter():
        if n.get("text", "").strip() or n.get("content-desc", "").strip():
            return (n.get("content-desc") or n.get("text")).strip()
    return ""


problems = []
for node in root.iter("node"):
    if (
        node.get("class") == "android.widget.Button"
        and node.get("enabled") == "true"
        and node.get("clickable") != "true"
    ):
        problems.append(f"can't activate  at {node.get('bounds')}  \"{label(node)[:50]}\"")
        continue
    if node.get("clickable") != "true" and node.get("long-clickable") != "true":
        continue
    m = re.findall(r"\d+", node.get("bounds", ""))
    if len(m) != 4:
        continue
    x1, y1, x2, y2 = map(int, m)
    w, h = (x2 - x1) / scale, (y2 - y1) / scale
    if w == 0 or h == 0:
        continue  # off screen
    name = label(node)
    # Cut by the screen's edge (scrolled under a pinned bar or the bottom):
    # its size here isn't its real size.
    clipped = y1 <= 0 or y2 >= screen_h
    where = f"at ({x1},{y1}) {w:.0f}x{h:.0f} dp"
    if not name:
        problems.append(f"no label        {where}  [{node.get('class')}]")
    elif (w < 47.5 or h < 47.5) and not clipped:
        problems.append(f"under 48 dp     {where}  \"{name[:50]}\"")

package = next((n.get("package") for n in root.iter("node")), "?")
print(f"Screen of {package}: {sum(1 for _ in root.iter('node'))} nodes")
if problems:
    print("\n".join(problems))
    sys.exit(1)
print("OK: every button can be activated, has a label and is at least 48 dp")
PY
