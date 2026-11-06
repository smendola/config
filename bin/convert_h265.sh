#!/usr/bin/env bash
# convert_h265.sh
# Re-encodes DJI Mini4 Pro footage (hevc/hvc1, 10-bit, HDR BT.2020/HLG) to H.265
# Retains: fps, resolution, pixel format (10-bit), color metadata (HDR)
# Output: <original_name>_h265.MP4 in the same directory as the input
#
# Usage:
#   ./convert_h265.sh file1.MP4 [file2.MP4 ...]
#   ./convert_h265.sh /path/to/folder/*.MP4
#
# Requirements: ffmpeg with libx265 support

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
CRF=22          # Quality: lower = better quality / larger file. 18–28 is typical.
                # DJI originals are ~91 Mbps; CRF 22 yields ~20–35 Mbps at 4K.
PRESET="fast"   # Encoding speed preset: ultrafast/superfast/veryfast/faster/fast/
                # medium/slow/slower/veryslow. Slower = better compression.
# ─────────────────────────────────────────────────────────────────────────────

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <input.MP4> [input2.MP4 ...]"
    exit 1
fi

for INPUT in "$@"; do
    if [[ ! -f "$INPUT" ]]; then
        echo "⚠  Skipping (not a file): $INPUT"
        continue
    fi

    DIR="$(dirname "$INPUT")"
    BASE="$(basename "$INPUT")"
    NAME="${BASE%.*}"       # filename without extension
    EXT="${BASE##*.}"       # original extension (MP4)

    OUTPUT="${DIR}/${NAME}_h265.${EXT}"

    if [[ -f "$OUTPUT" ]]; then
        echo "⚠  Output already exists, skipping: $OUTPUT"
        continue
    fi

    echo "▶  Encoding: $INPUT"
    echo "   → $OUTPUT"

    ffmpeg -hide_banner -loglevel info \
        -i "$INPUT" \
        -map 0:v:0 \
        -c:v libx265 \
        -crf "$CRF" \
        -preset "$PRESET" \
        -x265-params \
            "keyint=60:min-keyint=1:bframes=3:\
colorprim=bt2020:transfer=arib-std-b67:colormatrix=bt2020nc:\
repeat-headers=1" \
        -pix_fmt yuv420p10le \
        -color_range tv \
        -colorspace bt2020nc \
        -color_trc arib-std-b67 \
        -color_primaries bt2020 \
        -tag:v hvc1 \
        -an \
        -map_metadata 0 \
        -movflags +faststart \
        "$OUTPUT" \
    && echo "✔  Done: $OUTPUT" \
    || echo "✘  Failed: $INPUT"

    echo ""
done
