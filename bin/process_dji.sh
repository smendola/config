#!/usr/bin/env bash
# Generate H.265 and AV1 directly from each DJI original (10-bit BT.2020/HLG).
# Outputs are relative to the current working directory. No audio is retained.
# Usage: ./process_dji.sh FILE_OR_FOLDER [FILE_OR_FOLDER...]
# Folder arguments expand to immediate MP4, JPG and DNG files (not recursive).
# JPG and DNG files are copied with timestamps preserved.
# Requirements: ffmpeg with hevc_nvenc, av1_nvenc, scale_cuda, and an
# AV1-capable NVIDIA GPU with a compatible driver.

set -euo pipefail

# NVENC quality: lower CQ = better quality / larger files (not x265 CRF).
H265_CQ=20
H265_PRESET="p5"
CQ=20
AV1_PRESET="p5"

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") FILE_OR_FOLDER [FILE_OR_FOLDER...]"
    echo ""
    echo "Converts DJI videos to both 10-bit H.265 and AV1 using CUDA/NVENC."
    echo "Preserves resolution, frame rate, and BT.2020/HLG color; omits audio."
    echo "Folder arguments include immediate MP4, JPG and DNG files (not recursive)."
    echo "JPG and DNG files are copied, preserving timestamps; originals stay in place."
    echo ""
    echo "Outputs relative to the current working directory:"
    echo "  ./H265/<original_name>_h265.MP4"
    echo "  ./AV1/<original_name>_av1.MP4"
    echo "  ./JPG/<original_filename>"
    echo "  ./DNG/<original_filename>"
    echo "Existing output files are skipped."
    exit 1
fi

mkdir -p ./H265 ./AV1
STATUS=0

shopt -s nullglob
INPUTS=()
for ARG in "$@"; do
    if [[ -d "$ARG" ]]; then
        FILES=()
        for FILE in "$ARG"/*.[mM][pP]4 "$ARG"/*.[jJ][pP][gG] "$ARG"/*.[dD][nN][gG]; do
            [[ -f "$FILE" ]] && FILES+=("$FILE")
        done
        if [[ ${#FILES[@]} -eq 0 ]]; then
            echo "⚠  No MP4, JPG or DNG files in folder: $ARG"
        fi
        INPUTS+=("${FILES[@]}")
    else
        INPUTS+=("$ARG")
    fi
done

for INPUT in "${INPUTS[@]}"; do
    if [[ ! -f "$INPUT" ]]; then
        echo "⚠  Skipping (not a file): $INPUT"
        STATUS=1
        continue
    fi

    BASE="$(basename "$INPUT")"
    NAME="${BASE%.*}"
    EXT="${BASE##*.}"

    case "${EXT^^}" in
        JPG|DNG)
            OUTPUT_DIR="./${EXT^^}"
            OUTPUT="${OUTPUT_DIR}/${BASE}"
            mkdir -p "$OUTPUT_DIR"
            if [[ -e "$OUTPUT" ]]; then
                echo "⚠  Output already exists, skipping: $OUTPUT"
            elif cp -n --preserve=timestamps -- "$INPUT" "$OUTPUT"; then
                echo "✔  Copied: $INPUT → $OUTPUT"
            else
                echo "✘  Copy failed: $INPUT"
                STATUS=1
            fi
            continue
            ;;
    esac

    for FORMAT in h265 av1; do
        if [[ "$FORMAT" == h265 ]]; then
            OUTPUT="./H265/${NAME}_h265.MP4"
            VIDEO_OPTIONS=(
                -c:v hevc_nvenc -profile:v main10 -preset "$H265_PRESET"
                -rc vbr -cq "$H265_CQ" -b:v 0
                -g 60 -bf 3 -tag:v hvc1
            )
        else
            OUTPUT="./AV1/${NAME}_av1.MP4"
            VIDEO_OPTIONS=(
                -c:v av1_nvenc -preset "$AV1_PRESET"
                -rc vbr -cq "$CQ" -b:v 0
            )
        fi

        if [[ -e "$OUTPUT" ]]; then
            echo "⚠  Output already exists, skipping: $OUTPUT"
            continue
        fi

        echo "▶  Encoding: $INPUT"
        echo "   → $OUTPUT"

        if ffmpeg -hide_banner -loglevel info -nostdin -n \
            -hwaccel cuda -hwaccel_output_format cuda \
            -i "$INPUT" \
            -map 0:v:0 \
            -vf "scale_cuda=format=p010le" \
            "${VIDEO_OPTIONS[@]}" \
            -color_range tv \
            -colorspace bt2020nc \
            -color_trc arib-std-b67 \
            -color_primaries bt2020 \
            -an -map_metadata 0 -movflags +faststart \
            "$OUTPUT"; then
            echo "✔  Done: $OUTPUT"
        else
            echo "✘  Failed: $INPUT ($FORMAT)"
            echo "   Any partial output must be removed before retrying: $OUTPUT"
            STATUS=1
        fi

        echo ""
    done
done

exit "$STATUS"
