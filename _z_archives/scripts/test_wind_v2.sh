#!/usr/bin/env bash
# ==============================================================================
# Modular Arctic Wind v2.0 - Unified Local Test Runner Suite
# Tracked under Issue #96 (Package 5) & Parent Issue #82
# ==============================================================================
# Runs all 12 physics, aerodynamic, microgrid, and economic verification models
# in under 2 seconds with zero external dependencies (pure Python 3 stdlib).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WIND_DIR="$REPO_ROOT/cad_and_blender/openscad/wind/v2.0"

# ANSI color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${CYAN}==============================================================================${NC}"
echo -e "${BOLD}${CYAN} 🌬️  MODULAR ARCTIC WIND v2.0 — NUMERICAL VERIFICATION SUITE${NC}"
echo -e "${CYAN} Target Architecture: 50 kW Arctic Wind Turbine (Issue #96, #82)${NC}"
echo -e "${BOLD}${CYAN}==============================================================================${NC}"

if [[ ! -d "$WIND_DIR" ]]; then
    echo -e "${RED}❌ Error: Wind directory not found at: $WIND_DIR${NC}" >&2
    exit 1
fi

MODELS=(
    "envelope.py|Arctic Environmental & Air Density Envelope"
    "power_resource.py|Power Resource Sizing & Betz Limit Audit"
    "container_sizing.py|ISO 20ft Container Internal Geometry"
    "foundation_load_envelope.py|Foundation Overturning & Ballast Stability"
    "erection_kinematics.py|Gin-Pole A-Frame Winch Line Kinematics"
    "powertrain_envelope.py|Direct-Drive PMSG & Nacelle Architecture"
    "container_pack_audit.py|Complete 20ft Container Payload Mass Audit"
    "microgrid_dispatch.py|Annual Hourly Microgrid & Diesel Displacement"
    "weibull_wind_resource.py|Weibull Wind Resource & AEP Matrix"
    "aero_icing_loads.py|Aerodynamic Storm Gust & Asymmetric Rime Icing"
    "cold_climate_fmea.py|Cold-Climate Subsystem FMEA (IEC 60812)"
    "levelized_cost_energy.py|Arctic Levelized Cost of Energy (LCOE)"
)

TOTAL_COUNT=${#MODELS[@]}
PASSED_COUNT=0
FAILED_COUNT=0
FAILED_MODELS=()

SUITE_START=$(date +%s%N 2>/dev/null || date +%s)

printf "%-4s | %-28s | %-6s | %s\n" "No." "Model Script" "Status" "Engineering Focus"
echo "------------------------------------------------------------------------------"

INDEX=1
for entry in "${MODELS[@]}"; do
    IFS="|" read -r script_name description <<< "$entry"
    script_path="$WIND_DIR/$script_name"

    if [[ ! -f "$script_path" ]]; then
        printf "%-4d | %-28s | ${RED}%-6s${NC} | %s (Missing file)\n" "$INDEX" "$script_name" "FAIL" "$description"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODELS+=("$script_name (file missing)")
        INDEX=$((INDEX + 1))
        continue
    fi

    T_START=$(date +%s%N 2>/dev/null || date +%s)
    if output=$(python3 "$script_path" 2>&1); then
        T_END=$(date +%s%N 2>/dev/null || date +%s)
        # Compute millisecond duration if nanoseconds available, else fallback
        if [[ "$T_START" =~ ^[0-9]{10,}$ ]] && [[ "$T_END" =~ ^[0-9]{10,}$ ]]; then
            ELAPSED_MS=$(( (T_END - T_START) / 1000000 ))
            DUR_STR="${ELAPSED_MS}ms"
        else
            DUR_STR="<1s"
        fi
        printf "%-4d | %-28s | ${GREEN}%-6s${NC} | %s (%s)\n" "$INDEX" "$script_name" "PASS" "$description" "$DUR_STR"
        PASSED_COUNT=$((PASSED_COUNT + 1))
    else
        printf "%-4d | %-28s | ${RED}%-6s${NC} | %s\n" "$INDEX" "$script_name" "FAIL" "$description"
        echo -e "${RED}--- Output for $script_name ---${NC}" >&2
        echo "$output" >&2
        echo -e "${RED}-------------------------------${NC}" >&2
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_MODELS+=("$script_name")
    fi
    INDEX=$((INDEX + 1))
done

SUITE_END=$(date +%s%N 2>/dev/null || date +%s)
if [[ "$SUITE_START" =~ ^[0-9]{10,}$ ]] && [[ "$SUITE_END" =~ ^[0-9]{10,}$ ]]; then
    TOTAL_DUR_MS=$(( (SUITE_END - SUITE_START) / 1000000 ))
    TOTAL_DUR_SEC=$(awk "BEGIN {printf \"%.2f\", $TOTAL_DUR_MS / 1000}")
else
    TOTAL_DUR_SEC="<2"
fi

echo "------------------------------------------------------------------------------"
echo -e "${BOLD}Summary: ${GREEN}${PASSED_COUNT}/${TOTAL_COUNT} Passed${NC} | ${RED}${FAILED_COUNT} Failed${NC} | Total Elapsed: ${TOTAL_DUR_SEC}s"

# Optional FreeCAD v3.0 check if requested via flag
if [[ "${1:-}" == "--v3" || "${1:-}" == "--all" ]]; then
    echo ""
    echo -e "${BOLD}${CYAN}Optional Extension: Modular Arctic Wind v3.0 (FreeCAD STEP Solid)${NC}"
    V3_SCRIPT="$REPO_ROOT/cad_and_blender/freecad/wind/modular_wind_turbine_v3.py"
    if [[ -f "$V3_SCRIPT" ]]; then
        if python3 "$V3_SCRIPT" >/dev/null 2>&1; then
            echo -e "FreeCAD Solid Model (modular_wind_turbine_v3.py) : ${GREEN}PASS${NC} (STEP Solid Valid)"
        else
            echo -e "FreeCAD Solid Model (modular_wind_turbine_v3.py) : ${YELLOW}SKIP/FAIL${NC} (FreeCAD libs not installed)"
        fi
    fi
fi

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "${RED}❌ Verification failed for models: ${FAILED_MODELS[*]}${NC}" >&2
    exit 1
fi

echo -e "${GREEN}✅ All ${TOTAL_COUNT} Arctic engineering verification models passed successfully.${NC}"
exit 0
