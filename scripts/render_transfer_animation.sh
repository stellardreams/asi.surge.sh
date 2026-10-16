#!/usr/bin/env bash
# render_transfer_animation.sh -- Render multi-frame animation of arm transfer sequence
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMU_DIR="${SCRIPT_DIR}/../cad_and_blender/openscad/amu_surface"
OUT_GIF="${AMU_DIR}/amu_surface_transfer_docking.gif"
OUT_MP4="${AMU_DIR}/amu_surface_transfer_docking.mp4"
FRAMES_DIR="/tmp/amu_transfer_frames"

rm -rf "${FRAMES_DIR}"
mkdir -p "${FRAMES_DIR}"

NUM_FRAMES=40
FPS=5

echo "Rendering ${NUM_FRAMES} frames of AMU ceiling-to-rover transfer docking..."

for (( i=0; i<NUM_FRAMES; i++ )); do
    # Calculate t from 0.0 to 1.0
    t=$(awk -v i="$i" -v n="$NUM_FRAMES" 'BEGIN { printf "%.4f", i / (n - 1) }')
    frame_png=$(printf "${FRAMES_DIR}/frame_%03d.png" "$i")
    
    openscad -o "${frame_png}" \
        -D "t_override=${t}" \
        --camera=4,8,4.5,60,0,225,27 --imgsize=1024,768 \
        "${AMU_DIR}/amu_surface_transfer_docking.scad" > /dev/null 2>&1
    
    printf "."
done
echo ""

echo "Compiling animated GIF (${OUT_GIF})..."
ffmpeg -y -framerate "${FPS}" -i "${FRAMES_DIR}/frame_%03d.png" \
    -vf "fps=${FPS},scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    "${OUT_GIF}"

echo "Compiling MP4 video (${OUT_MP4})..."
ffmpeg -y -framerate "${FPS}" -i "${FRAMES_DIR}/frame_%03d.png" \
    -c:v libx264 -pix_fmt yuv420p -crf 20 \
    "${OUT_MP4}"

echo "Clean up temporary frames..."
rm -rf "${FRAMES_DIR}"

echo "Transfer docking animation rendered successfully:"
ls -lh "${OUT_GIF}" "${OUT_MP4}"
