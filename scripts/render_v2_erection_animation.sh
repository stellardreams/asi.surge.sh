#!/usr/bin/env bash
set -euo pipefail

# render_v2_erection_animation.sh -- Render tilt-up erection animation for Wind v2.0
OUT_DIR="/tmp/wind_v2_anim_frames"
SCAD_FILE="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.scad"
GIF_OUT="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.gif"
MP4_OUT="/vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.mp4"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.png

echo "Rendering 31 frames of mast erection (0° to 90°)..."
for i in $(seq 0 30); do
    angle=$(echo "scale=1; $i * 3.0" | bc)
    frame=$(printf "%03d" "$i")
    openscad -o "$OUT_DIR/frame_${frame}.png" \
             -D "tilt_angle=${angle}" \
             --imgsize=960,720 \
             --camera=12000,-16000,10000,3000,0,8000 \
             --colorscheme=Tomorrow \
             "$SCAD_FILE" >/dev/null 2>&1
    echo -n "."
done
echo " done."

echo "Stitching GIF..."
ffmpeg -y -framerate 10 -i "$OUT_DIR/frame_%03d.png" \
       -vf "split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" \
       "$GIF_OUT"

echo "Stitching MP4..."
ffmpeg -y -framerate 10 -i "$OUT_DIR/frame_%03d.png" \
       -c:v libx264 -pix_fmt yuv420p \
       "$MP4_OUT"

echo "Animation generated: $GIF_OUT and $MP4_OUT"
ls -lh "$GIF_OUT" "$MP4_OUT"
