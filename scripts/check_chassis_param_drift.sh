#!/usr/bin/env bash
# =============================================================================
# check_chassis_param_drift.sh — issue #82
#
# Guards the params that cad_and_blender/openscad/wind/amu_wind_chassis_v1.scad
# re-declares rather than inheriting. The wind chassis is standalone because
# `use <>` freezes module params and `include <>` executes the canonical file's
# top-level render — so the shared values are duplicated across two files by
# necessity. This script detects divergence.
#
# It does NOT prevent drift; it reports it. The structural fix would be a shared
# params include, which requires editing the canonical file. Deferred to #5.
#
# Usage:  scripts/check_chassis_param_drift.sh
# Exit:   0 = in sync, 1 = drift detected, 2 = setup problem
# =============================================================================

set -uo pipefail

CANONICAL="cad_and_blender/openscad/opencode/amu_CORA-M-arm-opencode_v1.scad"
WIND="cad_and_blender/openscad/wind/amu_wind_chassis_v1.scad"

# Params that must agree. RIVET_* and the hull dims are the load-bearing set:
# changing them in one file silently desynchronises rivet exclusion maths,
# caliper lane clearances, and the transport envelope calculation.
PARAMS=(
  MMS_RADIUS
  MMS_LENGTH
  WALL_THICK
  RIVET_SPACING
  RIVET_R
  RIVET_H
  RIVET_LANE_EXCLUDE
  RIVET_APAS_EXCLUDE
  ROOF_HATCH_X
  APAS_RADIUS
)

if [[ ! -f "$CANONICAL" || ! -f "$WIND" ]]; then
  echo "ERROR: expected files not found. Run from the repo root." >&2
  echo "  canonical: $CANONICAL" >&2
  echo "  wind:      $WIND" >&2
  exit 2
fi

# Extract "<name> = <value>;" and normalise whitespace and trailing comment.
# Anchor on the assignment so calls like RIVET_R = ... inside module bodies
# (the via_ferrata_rivet defaults) are not mistaken for the top-level param.
extract() {
  local file="$1" name="$2"
  grep -E "^[[:space:]]*${name}[[:space:]]*=" "$file" \
    | head -n 1 \
    | sed -E 's|//.*||' \
    | tr -d '[:space:]' \
    | sed -E 's/;$//'
}

drift=0

printf '%-22s %-14s %-14s\n' "PARAM" "CANONICAL" "WIND"
printf '%s\n' "--------------------------------------------------"

for p in "${PARAMS[@]}"; do
    c=$(extract "$CANONICAL" "$p" | sed -E 's/^[A-Z_]+=//')
    w=$(extract "$WIND" "$p" | sed -E 's/^[A-Z_]+=//')

  if [[ -z "$c" ]]; then
    printf '%-22s %-14s %-14s %s\n' "$p" "${c:-<absent>}" "${w:-<absent>}" "MISSING-IN-CANONICAL"
    drift=1
  elif [[ -z "$w" ]]; then
    printf '%-22s %-14s %-14s %s\n' "$p" "$c" "<absent>" "MISSING-IN-WIND"
    drift=1
  elif [[ "$c" == "$w" ]]; then
    printf '%-22s %-14s %-14s %s\n' "$p" "$c" "$w" "ok"
  else
    printf '%-22s %-14s %-14s %s\n' "$p" "$c" "$w" "DRIFT"
    drift=1
  fi
done

echo
if [[ $drift -eq 0 ]]; then
  echo "PASS — wind chassis params match canonical."
  exit 0
fi

cat >&2 <<'EOF'
FAIL — param drift detected.

The wind chassis cannot inherit these params: `use <>` does not let consumer-side
overrides reach module bodies, and `include <>` would execute the canonical file's
top-level variant_dual() render into a chassis-only file. So the values are
duplicated on purpose, and this check guards that duplication.

To resolve, update the drifted value in BOTH files, then re-run. If the drift is
intentional, add the param to the ignore list in this script with a comment saying
why — do not silently delete the check.

Longer term, a shared params include would remove the duplication entirely. That
requires editing amu_CORA-M-arm-opencode_v1.scad and is deferred to issue #5.
EOF
exit 1
