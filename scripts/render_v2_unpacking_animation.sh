#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="/tmp/wind_v2_unpack_frames"
SCAD_FILE="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_container_unpacking.scad"
GIF_OUT="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_container_unpacking.gif"
MP4_OUT="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_container_unpacking.mp4"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.png

echo "Rendering 31 frames of container unpacking sequence (stage 0.00 to 1.00)..."
for i in $(seq 0 30); do
    st=$(awk -v i="$i" 'BEGIN { printf "%.3f", i / 30.0 }')
    frame=$(printf "%03d" "$i")
    openscad -o "$OUT_DIR/frame_${frame}.png" \
             -D "stage=${st}" \
             --imgsize=1024,768 \
             --camera=12000,-18000,10000,2500,0,1200 \
             --colorscheme=Tomorrow \
             "$SCAD_FILE" >/dev/null 2>&1
    echo -n "."
done
echo " done rendering."

echo "Stitching GIF..."
ffmpeg -y -framerate 10 -i "$OUT_DIR/frame_%03d.png" \
       -vf "split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" \
       "$GIF_OUT" >/dev/null 2>&1

echo "Stitching MP4..."
ffmpeg -y -framerate 10 -i "$OUT_DIR/frame_%03d.png" \
       -c:v libx264 -pix_fmt yuv420p \
       "$MP4_OUT" >/dev/null 2>&1

echo "Unpacking animation generated:"
ls -lh "$GIF_OUT" "$MP4_OUT"
