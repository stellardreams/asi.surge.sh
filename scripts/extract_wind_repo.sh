#!/usr/bin/env bash
# ==============================================================================
# Modular Arctic Wind Architecture - Standalone Repository Extraction Tool
# Tracked under Issue #96 (Package 5) & Parent Issue #82
# Protocol specification: docs/repo_extraction_manifest.md
# ==============================================================================
# Surgically extracts all wind engineering CAD models, physics validation suites,
# specifications, render pipelines, and workflows into an independent repository.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ANSI color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}==============================================================================${NC}"
echo -e "${BOLD}${CYAN} 📦 MODULAR ARCTIC WIND — SURGICAL REPOSITORY EXTRACTION TOOL${NC}"
echo -e "${CYAN} Protocol: docs/repo_extraction_manifest.md (Issue #96, #82)${NC}"
echo -e "${BOLD}${CYAN}==============================================================================${NC}"

# Target destination directory
DEST_DIR="${1:-/tmp/modular-arctic-wind-extracted}"
DRY_RUN=false

if [[ "${2:-}" == "--dry-run" || "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    if [[ "${1:-}" == "--dry-run" ]]; then
        DEST_DIR="/tmp/modular-arctic-wind-extracted"
    fi
fi

echo -e "${BOLD}Target Repository Destination:${NC} ${YELLOW}$DEST_DIR${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}Mode: DRY-RUN (no files will be written)${NC}"
fi

# Verification of source tree
WIND_OPENSCAD_SRC="$REPO_ROOT/cad_and_blender/openscad/wind"
WIND_FREECAD_SRC="$REPO_ROOT/cad_and_blender/freecad/wind"
WIND_SPEC_SRC="$REPO_ROOT/docs/specifications/modular_arctic_wind_architecture.md"
MANIFEST_SRC="$REPO_ROOT/docs/repo_extraction_manifest.md"

if [[ ! -d "$WIND_OPENSCAD_SRC/v2.0" ]]; then
    echo -e "${RED}❌ Error: Source directory $WIND_OPENSCAD_SRC/v2.0 missing!${NC}" >&2
    exit 1
fi

echo -e "\n[1/5] Initializing target standalone repository structure..."
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$DEST_DIR"
    mkdir -p "$DEST_DIR/cad/openscad/v2.0"
    mkdir -p "$DEST_DIR/cad/openscad/archive/v1.0"
    mkdir -p "$DEST_DIR/cad/freecad"
    mkdir -p "$DEST_DIR/cad/step_exports"
    mkdir -p "$DEST_DIR/docs/specifications"
    mkdir -p "$DEST_DIR/scripts"
    mkdir -p "$DEST_DIR/.github/workflows"
fi

echo -e "[2/5] Copying CAD assets and analytical physics suites..."
if [[ "$DRY_RUN" == false ]]; then
    # OpenSCAD v2.0
    cp -r "$WIND_OPENSCAD_SRC/v2.0/"* "$DEST_DIR/cad/openscad/v2.0/"
    # Historical v1.0 archive
    if [[ -d "$WIND_OPENSCAD_SRC/archive/v1.0" ]]; then
        cp -r "$WIND_OPENSCAD_SRC/archive/v1.0/"* "$DEST_DIR/cad/openscad/archive/v1.0/"
    fi
    # FreeCAD wind modules & STEP models
    if [[ -d "$WIND_FREECAD_SRC" ]]; then
        cp -r "$WIND_FREECAD_SRC/"* "$DEST_DIR/cad/freecad/"
    fi
    if [[ -f "$REPO_ROOT/cad_and_blender/freecad/step_exports/modular_wind_turbine_v3.step" ]]; then
        cp "$REPO_ROOT/cad_and_blender/freecad/step_exports/modular_wind_turbine_v3.step" "$DEST_DIR/cad/step_exports/"
    fi
    if [[ -f "$REPO_ROOT/cad_and_blender/freecad/step_exports/modular_wind_turbine_v2.step" ]]; then
        cp "$REPO_ROOT/cad_and_blender/freecad/step_exports/modular_wind_turbine_v2.step" "$DEST_DIR/cad/step_exports/"
    fi
fi

echo -e "[3/5] Migrating documentation, specifications, and render tooling..."
if [[ "$DRY_RUN" == false ]]; then
    if [[ -f "$WIND_SPEC_SRC" ]]; then
        cp "$WIND_SPEC_SRC" "$DEST_DIR/docs/specifications/"
    fi
    if [[ -f "$MANIFEST_SRC" ]]; then
        cp "$MANIFEST_SRC" "$DEST_DIR/docs/"
    fi
    cp "$REPO_ROOT/scripts/render_v2_"*.sh "$DEST_DIR/scripts/" 2>/dev/null || true
fi

echo -e "[4/5] Authoring standalone README.md & automated test harness..."
if [[ "$DRY_RUN" == false ]]; then
    cat > "$DEST_DIR/README.md" << 'EOF'
# Modular Arctic Wind Turbine Architecture (50 kW)

Autonomous, containerized polar wind power generation system engineered for extreme northern conditions:
- **Nominal Electrical Rating**: 50 kW at 10.5 m/s rated wind speed.
- **Extreme Survival**: −60 °C structural operation in dense polar air (\rho = 1.656 kg/m³), 120 km/h operating band, 151 km/h 50-year storm gusts.
- **Containerized Logistics**: 100% packaged inside a single 20 ft ISO high-cube container (9,216.8 kg \le 10,886 kg limit).
- **Crane-Less Erection**: Integrated container A-frame gin-pole and winch line rigging for remote field installation.
- **Airfoil Aerodynamics**: Segmented (\le 1.90 m) NACA 4415/4412 lofted rotor blades with thermal anti-icing.
- **Microgrid Hybridization**: 400V 3-phase AFE inverter with autonomous droop control and 50 kWh BESS buffer, displacing 21,087 L/year of diesel fuel.

## Repository Layout
- `cad/freecad/`: Parametric FreeCAD 1.0.0 Python solid model generators and 360° turntables.
- `cad/step_exports/`: Monolithic ISO 10303 STEP solid models (`modular_wind_turbine_v3.step`).
- `cad/openscad/v2.0/`: OpenSCAD visual assemblies and 12 physics verification models.
- `docs/specifications/`: Authoritative technical specification document.
- `scripts/`: Local test runners and render automation pipelines.

## Quick Start: Verification
Run the 12-model numerical verification suite:
```bash
./scripts/test_wind.sh
```
EOF

    # Author standalone test runner script
    cat > "$DEST_DIR/scripts/test_wind.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WIND_DIR="$REPO_ROOT/cad/openscad/v2.0"

echo "=============================================================================="
echo " 🌬️  MODULAR ARCTIC WIND — STANDALONE NUMERICAL VERIFICATION SUITE"
echo "=============================================================================="

MODELS=(
    "envelope.py:Arctic Environmental & Air Density Envelope"
    "power_resource.py:Power Resource Sizing & Betz Limit Audit"
    "container_sizing.py:ISO 20ft Container Internal Geometry"
    "foundation_load_envelope.py:Foundation Overturning & Ballast Stability"
    "erection_kinematics.py:Gin-Pole A-Frame Winch Line Kinematics"
    "powertrain_envelope.py:Direct-Drive PMSG & Nacelle Architecture"
    "container_pack_audit.py:Complete 20ft Container Payload Mass Audit"
    "microgrid_dispatch.py:Annual Hourly Microgrid & Diesel Displacement"
    "weibull_wind_resource.py:Weibull Wind Resource & AEP Matrix"
    "aero_icing_loads.py:Aerodynamic Storm Gust & Asymmetric Rime Icing"
    "cold_climate_fmea.py:Cold-Climate Subsystem FMEA (IEC 60812)"
    "levelized_cost_energy.py:Arctic Levelized Cost of Energy (LCOE)"
)

PASSED=0
TOTAL=${#MODELS[@]}
for entry in "${MODELS[@]}"; do
    IFS=":" read -r script desc <<< "$entry"
    if python3 "$WIND_DIR/$script" >/dev/null 2>&1; then
        printf "PASS | %-28s | %s\n" "$script" "$desc"
        PASSED=$((PASSED + 1))
    else
        printf "FAIL | %-28s | %s\n" "$script" "$desc"
        exit 1
    fi
done

echo "=============================================================================="
echo "Summary: $PASSED/$TOTAL models passed in standalone destination."
echo "✅ Standalone repository integrity verified."
exit 0
EOF
    chmod +x "$DEST_DIR/scripts/test_wind.sh"

    # Copy CI workflow
    cat > "$DEST_DIR/.github/workflows/ci.yml" << 'EOF'
name: Arctic Wind CI Verification
on: [push, pull_request, workflow_dispatch]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Run Verification Suite
        run: |
          chmod +x scripts/test_wind.sh
          ./scripts/test_wind.sh
EOF
fi

echo -e "[5/5] Running in-situ verification test on extracted repository..."
if [[ "$DRY_RUN" == false ]]; then
    if "$DEST_DIR/scripts/test_wind.sh"; then
        echo -e "${GREEN}✅ Standalone extraction verification passed 100%!${NC}"
    else
        echo -e "${RED}❌ Standalone verification failed in $DEST_DIR!${NC}" >&2
        exit 1
    fi
fi

echo -e "\n${BOLD}${GREEN}==============================================================================${NC}"
echo -e "${BOLD}${GREEN} 🎉 EXTRACTION COMPLETE: Modular Arctic Wind repository ready at:${NC}"
echo -e "${BOLD}${GREEN}    $DEST_DIR${NC}"
echo -e "${BOLD}${GREEN}==============================================================================${NC}"
exit 0
