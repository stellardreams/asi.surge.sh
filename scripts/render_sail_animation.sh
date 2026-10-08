#!/usr/bin/env bash
# =============================================================================
# render_sail_animation.sh — issue #82
#
# Renders an MP4 of the sail rocking, by sweeping $t over a range and stitching the
# frames with ffmpeg.
#
# OpenSCAD exposes $t, the animation time, which runs 0 -> 1 during an animated
# preview. Passing -D '$t=<value>' sets it for a headless render, which is all this
# script needs: no GUI, no replay, fully reproducible.
#
# Usage:
#   scripts/render_sail_animation.sh                 # 48 frames, 24 fps, 2 cycles
#   scripts/render_sail_animation.sh --frames 96 --fps 30
#   scripts/render_sail_animation.sh --cam 0,0,0,66,0,20,17
#   scripts/render_sail_animation.sh --still          # also emit a 3-tile contact sheet
#   scripts/render_sail_animation.sh --name stiction02 --az 215 --cam 0,0,0,74,0,0,9
#
# Named views already rendered (see wind/renders/):
#   amu_wind_sail_v5_anim_close_*   joint detail, default close preset
#   amu_wind_sail_v5_anim_wide_*     whole unit
#   stiction02_*                     rotated 215 deg onto the joint, datum off —
#                                    puts the flange, cassette gap and the bearing race
#                                    at the centre of frame. Command used:
#      scripts/render_sail_animation.sh --name stiction02 \
#        --cam 0,0,0,72,0,215,9.0 --size 900,900 \
#        --def SHOW_DATUM=false --frames 48 --fps 24 --still
#
# Exit: 0 = MP4 written, 1 = setup problem, 2 = openscad or ffmpeg missing
# =============================================================================

set -uo pipefail

SCAD="cad_and_blender/openscad/wind/amu_wind_sail_v5.scad"
OUTDIR="cad_and_blender/openscad/wind/renders"
FRAMES=48
FPS=24
WIDTH=880
HEIGHT=1050   # portrait: the sail is tall, landscape crops it and hides the rock
# --camera format is translate_x,y,z,ROT_x,y,z,DIST. Getting these two triples the
# wrong way round points the camera 66 units off to one side and yields blank
# frames that still assemble into a valid-looking MP4.
# Whole-unit view.
CAM_WIDE="0,0,0,66,0,20,15.0"
# Close on the sail foot. The oscillation is only a few degrees, and at the wide
# distance that moves very few pixels — the motion is essentially invisible there.
CAM_CLOSE="0,0,0,50,0,10,7.5"
VIEW="${VIEW:-close}"
BASENAME="${BASENAME:-amu_wind_sail_v5_anim}"
CAM=""
CAM_SET=0   # an explicit --cam must survive the view presets
AZ="${AZ:-}"   # optional azimuth override, appended as rot_z
EXTRA_DEFS=()
CLEAN=1
RENDER_MODE=0   # 0 = preview/throwntogether (fast, keeps model colours)
                # 1 = CGAL --render (F6-identical geometry, but headless PNG export
                #     applies a theme palette that OVERRIDES the model colour() calls,
                #     so ice/water blues are lost. Preview mode keeps them.)
CSFLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --frames) FRAMES="$2"; shift 2 ;;
    --fps)    FPS="$2";    shift 2 ;;
    --cam)    CAM="$2";    CAM_SET=1; shift 2 ;;
    --size)   IFS=',' read -r WIDTH HEIGHT <<< "$2"; shift 2 ;;
    --out)    OUTDIR="$2"; shift 2 ;;
    --keep)   CLEAN=0;     shift ;;
    --wide)   VIEW="wide"; shift ;;
    --close)  VIEW="close"; shift ;;
    --name)   BASENAME="$2"; shift 2 ;;
    --az)     AZ="$2"; shift 2 ;;   # rotate the camera azimuth, degrees
    --def)    EXTRA_DEFS+=("$2"); shift 2 ;;   # extra -D NAME=VALUE, repeatable
    --still)  STILL=1;     shift ;;
    --preview) RENDER_MODE=0; shift ;;
    --cgal)    RENDER_MODE=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

# Preset only if --cam was not given explicitly. Previously the presets ran
# unconditionally AFTER argument parsing, so --cam was silently discarded —
# the option had never once taken effect.
if [[ $CAM_SET -eq 0 ]]; then
  [[ "$VIEW" == "wide" ]] && CAM="$CAM_WIDE" || CAM="$CAM_CLOSE"
fi
# --az rotates the view about the vertical axis: split the camera string on its
# final field (dist) and replace rot_z (the one before it).
if [[ -n "$AZ" ]]; then
  IFS=, read -r -a _c <<< "$CAM"
  _c[$(( ${#_c[@]} - 2 ))]="$AZ"
  CAM=$(IFS=,; echo "${_c[*]}")
fi

command -v openscad >/dev/null || { echo "ERROR: openscad not found" >&2; exit 2; }
command -v ffmpeg    >/dev/null || { echo "ERROR: ffmpeg not found" >&2; exit 2; }
[[ -f "$SCAD" ]] || { echo "ERROR: $SCAD not found. Run from the repo root." >&2; exit 1; }

mkdir -p "$OUTDIR"
STAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Refuse to overwrite or delete anything that git already tracks. Renders have been
# committed by hand, and a broad cleanup glob silently removed tracked files twice.
TRACKED=$(git ls-files "$OUTDIR" 2>/dev/null || true)
NAME="${BASENAME}_${VIEW}_${STAMP}"

if [[ -n "$TRACKED" ]]; then
  echo "  note: $OUTDIR contains $(echo "$TRACKED" | wc -l) git-tracked file(s); this run will not touch them"
fi
echo "Rendering $FRAMES frames -> $OUTDIR/$NAME.mp4"
echo "  camera $CAM   size ${WIDTH}x${HEIGHT}   $FPS fps"
[[ ${#EXTRA_DEFS[@]} -gt 0 ]] && echo "  extra -D: ${EXTRA_DEFS[*]}"
echo "  mode $([[ $RENDER_MODE -eq 1 ]] && echo 'CGAL (--cgal, theme overrides colours)' || echo 'preview (fast, keeps model colours)')"

fail=0
for ((i = 0; i < FRAMES; i++)); do
  t=$(awk "BEGIN{printf \"%.6f\", $i/$FRAMES}")
  out=$(printf "%s/frame_%04d.png" "$OUTDIR" "$i")
  # extra -D passthrough, so a view can switch features off without editing the model
  XFLAG=""
  for d in "${EXTRA_DEFS[@]+"${EXTRA_DEFS[@]}"}"; do XFLAG+=" -D $d"; done

  RFLAG="--preview=throwntogether"
  [[ $RENDER_MODE -eq 1 ]] && RFLAG="--render"
  if ! openscad $RFLAG $XFLAG \
        -D "\$t=$t" \
        --camera="$CAM" \
        --imgsize="$WIDTH,$HEIGHT" \
        -o "$out" "$SCAD" 2>/tmp/opencode/openscad_anim_err.txt; then
    echo "  frame $i FAILED at t=$t" >&2
    sed -n '1,5p' /tmp/opencode/openscad_anim_err.txt >&2
    fail=1
    break
  fi
  # a zero-byte PNG means openscad fell back without producing anything
  if [[ ! -s "$out" ]]; then
    echo "  frame $i produced no output at t=$t" >&2
    fail=1
    break
  fi
  printf '\r  %d/%d' "$((i + 1))" "$FRAMES"
done
echo

if [[ $fail -eq 1 ]]; then
  echo "FAILED during frame export. Renders are partial; nothing written to MP4." >&2
  exit 1
fi

MP4="$OUTDIR/$NAME.mp4"
if ! ffmpeg -y -loglevel error -framerate "$FPS" \
      -i "$OUTDIR/frame_%04d.png" \
      -c:v libx264 -pix_fmt yuv420p -crf 20 "$MP4"; then
  echo "ERROR: ffmpeg failed to assemble the MP4." >&2
  exit 1
fi

if [[ "${STILL:-0}" == "1" ]]; then
  SHEET="$OUTDIR/${NAME}_contact.png"   # braces required: $NAME_contact would read as a different variable
  # three frames spread across the cycle: mid-lean, neutral, mid-lean opposite
  ffmpeg -y -loglevel error \
    -i "$OUTDIR/frame_$(printf '%04d' $((FRAMES * 0 / 8))).png" \
    -i "$OUTDIR/frame_$(printf '%04d' $((FRAMES * 4 / 8))).png" \
    -i "$OUTDIR/frame_$(printf '%04d' $((FRAMES * 6 / 8))).png" \
    -filter_complex "[0:v][1:v][2:v]hstack=inputs=3" "$SHEET" 2>/dev/null \
    && echo "  contact sheet -> $SHEET" \
    || echo "  (contact sheet skipped)"
fi

if [[ $CLEAN -eq 1 ]]; then
  # Only this run's frames. A broader glob (e.g. "$OUTDIR"/amu_wind_sail_v5_anim_*.mp4)
  # has already twice destroyed committed renders — do not reintroduce one.
  rm -f "$OUTDIR"/frame_*.png
  echo "  frames cleaned (--keep to retain them)"
fi

echo "Wrote $MP4"
exit 0
