#!/usr/bin/env bash
# =============================================================================
# render_turbine_animation.sh — Wind v2.0 Operational Animation (#82)
#
# Renders an animated GIF and MP4 of the fully erected 50 kW wind turbine rotor
# spinning at its rated direct-drive speed (65 RPM), by sweeping OpenSCAD's $t
# variable across [0, 1) and compiling with ffmpeg (palettegen + paletteuse).
#
# Usage:
#   scripts/render_turbine_animation.sh                    # Default: 24 frames, landscape view
#   scripts/render_turbine_animation.sh --view hero        # Hero upward perspective
#   scripts/render_turbine_animation.sh --view landscape   # Full system landscape perspective
#   scripts/render_turbine_animation.sh --view both        # Render both views
#   scripts/render_turbine_animation.sh --frames 36 --fps 24
#
# Outputs:
#   cad_and_blender/openscad/wind/v2.0/wind_v2_turbine_spinning_<view>.gif
#   cad_and_blender/openscad/wind/v2.0/wind_v2_turbine_spinning_<view>.mp4
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAD="${REPO_ROOT}/cad_and_blender/openscad/wind/v2.0/wind_v2_turbine_full.scad"
OUTDIR="${REPO_ROOT}/cad_and_blender/openscad/wind/v2.0"
FRAMES=24
FPS=20
VIEW="landscape"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --view)
            VIEW="$2"
            shift 2
            ;;
        --frames)
            FRAMES="$2"
            shift 2
            ;;
        --fps)
            FPS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

command -v openscad >/dev/null 2>&1 || { echo "Error: openscad not found" >&2; exit 2; }
command -v ffmpeg >/dev/null 2>&1 || { echo "Error: ffmpeg not found" >&2; exit 2; }

render_view() {
    local vname="$1"
    local cam="$2"
    local imgsize="$3"
    local tmpdir
    tmpdir="$(mktemp -d -t turbine_anim_XXXXXX)"
    trap 'rm -rf "${tmpdir}"' RETURN

    echo "==> Rendering ${FRAMES} frames for view '${vname}' (${imgsize})..."

    for (( i=0; i<FRAMES; i++ )); do
        python3 -c "
i = $i
n = $FRAMES
t = i / n
print(f'{t:.6f}')
" > "${tmpdir}/t_val.txt"
        t_val="$(cat "${tmpdir}/t_val.txt")"
        frame_file="${tmpdir}/frame_$(printf '%04d' "$i").png"

        openscad -o "${frame_file}" \
            --imgsize="${imgsize}" \
            --camera="${cam}" \
            -D "\$t=${t_val};" \
            "${SCAD}" >/dev/null 2>&1
    done

    local gif_out="${OUTDIR}/wind_v2_turbine_spinning_${vname}.gif"
    local mp4_out="${OUTDIR}/wind_v2_turbine_spinning_${vname}.mp4"
    local palette="${tmpdir}/palette.png"

    echo "==> Generating optimized GIF: ${gif_out}..."
    ffmpeg -y -framerate "${FPS}" -i "${tmpdir}/frame_%04d.png" \
        -vf "fps=${FPS},scale=iw:-1:flags=lanczos,palettegen=stats_mode=diff" \
        "${palette}" >/dev/null 2>&1

    ffmpeg -y -framerate "${FPS}" -i "${tmpdir}/frame_%04d.png" -i "${palette}" \
        -lavfi "fps=${FPS},scale=iw:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
        "${gif_out}" >/dev/null 2>&1

    echo "==> Generating MP4: ${mp4_out}..."
    ffmpeg -y -framerate "${FPS}" -i "${tmpdir}/frame_%04d.png" \
        -c:v libx264 -pix_fmt yuv420p -movflags +faststart \
        "${mp4_out}" >/dev/null 2>&1

    echo "==> Done: ${gif_out} ($(du -h "${gif_out}" | cut -f1)) & ${mp4_out} ($(du -h "${mp4_out}" | cut -f1))"
}

if [[ "${VIEW}" == "landscape" || "${VIEW}" == "both" ]]; then
    render_view "landscape" "0,0,14000,60,0,32,62000" "1024,576"
fi

if [[ "${VIEW}" == "hero" || "${VIEW}" == "both" ]]; then
    render_view "hero" "2500,-6000,24000,80,0,30,22000" "800,800"
fi
