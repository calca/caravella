"""Tiny adb + uiautomator driver for the emulator.

usage: ui.py dump                 -> list labelled nodes with centers
       ui.py tap <regex> [n]      -> tap the n-th (0) node whose text/desc matches
       ui.py shot <file.png>      -> screenshot
"""
import re
import subprocess
import sys
import time

ADB = ["adb", "-s", "emulator-5554"]


def nodes():
    subprocess.run(ADB + ["shell", "uiautomator", "dump", "/sdcard/ui.xml"], capture_output=True)
    xml = subprocess.run(ADB + ["shell", "cat", "/sdcard/ui.xml"], capture_output=True, text=True).stdout
    out = []
    for m in re.finditer(r"<node ([^>]*)>|<node ([^>]*)/>", xml):
        attrs = dict(re.findall(r'([\w-]+)="([^"]*)"', m.group(1) or m.group(2)))
        label = (attrs.get("text") or attrs.get("content-desc") or "").replace("&#10;", " | ")
        x1, y1, x2, y2 = map(int, re.findall(r"\d+", attrs.get("bounds", "[0,0][0,0]")))
        out.append((label, (x1 + x2) // 2, (y1 + y2) // 2, attrs.get("clickable") == "true",
                    attrs.get("class", ""), attrs.get("checked")))
    return out


def main():
    cmd = sys.argv[1]
    if cmd == "dump":
        for label, x, y, click, cls, checked in nodes():
            if label or cls.endswith("EditText"):
                print(f"{x:5d},{y:5d} {'C' if click else ' '} {cls.split('.')[-1]:12s} {checked or '':5s} {label[:90]}")
    elif cmd == "tap":
        pat = re.compile(sys.argv[2], re.I)
        idx = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        hits = [n for n in nodes() if pat.search(n[0])]
        if len(hits) <= idx:
            sys.exit(f"no match for {sys.argv[2]!r}")
        _, x, y, *_ = hits[idx]
        subprocess.run(ADB + ["shell", "input", "tap", str(x), str(y)])
        time.sleep(1.2)
        print(f"tapped {hits[idx][0][:60]!r} at {x},{y}")
    elif cmd == "shot":
        with open(sys.argv[2], "wb") as f:
            f.write(subprocess.run(ADB + ["exec-out", "screencap", "-p"], capture_output=True).stdout)


if __name__ == "__main__":
    main()
