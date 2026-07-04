#!/usr/bin/env python3
"""
Patch for Variety wallpaper changer (https://github.com/peterlevi/variety)

Fixes clock font resolution for ImageMagick 7+:
  - replace_clock_filter_fonts() now resolves %CLOCK_FONT_NAME / %DATE_FONT_NAME
    via fc-match to an actual font file path, instead of relying on a backtick
    subshell that shlex.split() never executes.

This lets you control the clock font purely via variety.conf:
    clock_font = Serif 70
    clock_date_font = Serif 30

And use %CLOCK_FONT_NAME / %DATE_FONT_NAME in your clock_filter string.

Usage:
    sudo python3 variety-font-fix.py          # apply
    sudo python3 variety-font-fix.py --revert # revert to original
"""

import sys
import os
import glob

OLD = """\
    def replace_clock_filter_fonts(self, clock_filter):
        clock_font_name, clock_font_size = Util.gtk_to_fcmatch_font(self.options.clock_font)
        date_font_name, date_font_size = Util.gtk_to_fcmatch_font(self.options.clock_date_font)
        clock_filter = clock_filter.replace("%CLOCK_FONT_NAME", clock_font_name)
        clock_filter = clock_filter.replace("%CLOCK_FONT_SIZE", clock_font_size)
        clock_filter = clock_filter.replace("%DATE_FONT_NAME", date_font_name)
        clock_filter = clock_filter.replace("%DATE_FONT_SIZE", date_font_size)
        return clock_filter"""

NEW = """\
    def replace_clock_filter_fonts(self, clock_filter):
        import subprocess as _sp

        def _resolve_font(fc_name):
            \"\"\"Resolve an fc-match font name (e.g. 'Serif:') to a .ttf path for ImageMagick.\"\"\"
            try:
                result = _sp.run(
                    ["fc-match", "-f", "%{file[0]}", fc_name],
                    capture_output=True, text=True, timeout=3
                )
                path = result.stdout.strip()
                if path:
                    return path
            except Exception:
                pass
            return fc_name  # fall back to raw name if fc-match fails

        clock_font_name, clock_font_size = Util.gtk_to_fcmatch_font(self.options.clock_font)
        date_font_name, date_font_size = Util.gtk_to_fcmatch_font(self.options.clock_date_font)
        clock_filter = clock_filter.replace("%CLOCK_FONT_NAME", _resolve_font(clock_font_name))
        clock_filter = clock_filter.replace("%CLOCK_FONT_SIZE", clock_font_size)
        clock_filter = clock_filter.replace("%DATE_FONT_NAME", _resolve_font(date_font_name))
        clock_filter = clock_filter.replace("%DATE_FONT_SIZE", date_font_size)
        return clock_filter"""


def find_target():
    candidates = glob.glob("/usr/lib/python3*/site-packages/variety/VarietyWindow.py")
    candidates += glob.glob("/usr/local/lib/python3*/site-packages/variety/VarietyWindow.py")
    candidates += glob.glob("/usr/share/variety/variety/VarietyWindow.py")
    if not candidates:
        sys.exit("ERROR: Could not find VarietyWindow.py. Is variety installed?")
    if len(candidates) > 1:
        print("Multiple candidates found, using first:")
        for c in candidates:
            print(f"  {c}")
    return candidates[0]


def apply(path, revert=False):
    with open(path, "r") as f:
        content = f.read()

    src, dst, action = (NEW, OLD, "revert") if revert else (OLD, NEW, "apply")

    if dst in content:
        print(f"Patch already {'reverted' if revert else 'applied'}: {path}")
        return

    if src not in content:
        sys.exit(
            f"ERROR: Could not find the expected code block in {path}.\n"
            "The patch may not be compatible with this version of Variety."
        )

    # Backup
    backup = path + ".orig"
    if not os.path.exists(backup):
        with open(backup, "w") as f:
            f.write(content)
        print(f"Backup saved: {backup}")

    with open(path, "w") as f:
        f.write(content.replace(src, dst))

    print(f"Patch {'reverted' if revert else 'applied'}: {path}")


if __name__ == "__main__":
    if os.geteuid() != 0:
        sys.exit("ERROR: Run with sudo.")
    revert = "--revert" in sys.argv
    apply(find_target(), revert=revert)
    print("Done. Restart Variety to apply.")
