# Wind v2.0 Standalone Repository Extraction Manifest

Exhaustive audit manifest and migration protocol for surgically exporting the **Wind v2.0 Modular Arctic Wind Generation** program into an independent repository (public or private) with zero broken dependencies.

Tracked under Parent Issue #82.

---

## 1. Architectural Self-Containment Audit

The Wind v2.0 codebase was designed from inception to be 100% physically decoupled from the host web application (`asi.surge.sh`). It has:
- **Zero npm / JavaScript dependencies.**
- **Zero build tool coupling** (runs purely via OpenSCAD and Python standard library).
- **Zero relative path imports** outside the `cad_and_blender/openscad/wind/` tree.

---

## 2. File Inventory for Migration

### A. Core CAD Models (`cad_and_blender/openscad/wind/v2.0/`)
| Source Path | Component / Package | Status |
| :--- | :--- | :---: |
| `wind_v2_foundation.scad` | Package 1 (#85): ISO container footing, gravel ballast & screw anchors | Verified ✅ |
| `wind_v2_mast_erection.scad` | Package 2 (#86): Modular mast sections, gin-pole A-frame & winch rigging | Verified ✅ |
| `wind_v2_nacelle.scad` | Package 3 (#87): Direct-drive PMSG, elevated shaft, yaw drives & cowl | Verified ✅ |
| `wind_v2_blade_joint.scad` | Package 4 (#88): 1.71 m modular blade, carbon box spar & heated foil | Verified ✅ |
| `wind_v2_container_stowage.scad` | Package 4 (#88): 20 ft ISO container internal racking & layout | Verified ✅ |
| `wind_v2_container_unpacking.scad`| Phase 2 / #88: Multi-stage field unpacking & deployment CAD | Verified ✅ |

### B. Numerical Analysis & Physics Envelopes (`cad_and_blender/openscad/wind/v2.0/`)
| Source Path | Verification Scope | Status |
| :--- | :--- | :---: |
| `envelope.py` | Arctic site envelope, cold air density ($1.35\times$) | Pass (`exit 0`) ✅ |
| `power_resource.py` | Sizing sweep across 25–100 kW wind power regimes | Pass (`exit 0`) ✅ |
| `container_sizing.py` | Geometric sectioning to fit ISO 20 ft internal envelope | Pass (`exit 0`) ✅ |
| `foundation_load_envelope.py` | Overturning moment safety ($FS = 2.45 \ge 1.50$) | Pass (`exit 0`) ✅ |
| `erection_kinematics.py` | Winch line tension ($48.2\text{ kN}$), Euler buckling ($FS = 3.82$) | Pass (`exit 0`) ✅ |
| `powertrain_envelope.py` | PMSG electromagnetic mass ($331.8\text{ kg}$), thermal self-heating ($+21.5\text{ }^\circ\text{C}$) | Pass (`exit 0`) ✅ |
| `container_pack_audit.py` | Full cargo mass reconciliation ($9\text{ }216.8\text{ kg} \le 10\text{ }886\text{ kg}$, $15.3\%$ margin) | Pass (`exit 0`) ✅ |
| `microgrid_dispatch.py` | 8760-hour diesel displacement simulation ($21\text{ }087\text{ L/yr}$ saved) | Pass (`exit 0`) ✅ |
| `weibull_wind_resource.py` | Weibull AEP matrix & capacity factor sensitivity ($186 - 360\text{ MWh/yr}$) | Pass (`exit 0`) ✅ |

### C. Technical Specifications & Release Notes
| Source Path | Document Role |
| :--- | :--- |
| `cad_and_blender/openscad/wind/v2.0/foundation.md` | Package 1 Foundation Design Report |
| `cad_and_blender/openscad/wind/v2.0/mast_erection.md` | Package 2 Kinematics & Winch Rigging Specification |
| `cad_and_blender/openscad/wind/v2.0/powertrain.md` | Package 3 Direct-Drive PMSG & Nacelle Architecture |
| `cad_and_blender/openscad/wind/v2.0/stowage_and_microgrid.md` | Package 4 Stowage & Microgrid Specifications |
| `cad_and_blender/openscad/wind/v2.0/microgrid_specs.md` | Microgrid Droop Control & AFE Inverter Specification |
| `docs/release_notes/v1.3.0-draft.md` | Living Project Tracker & Complete Engineering Release Notes |

### D. Render Pipelines & Visual Assets
| Source Path | Deliverable Format |
| :--- | :--- |
| `scripts/render_v2_erection_animation.sh` | Bash script: Mast erection render pipeline |
| `scripts/render_v2_unpacking_animation.sh` | Bash script: Container unpacking render pipeline |
| `cad_and_blender/openscad/wind/v2.0/*.gif` | Animated deployment and tilt-up GIFs |
| `cad_and_blender/openscad/wind/v2.0/*.mp4` | High-definition deployment and erection MP4 videos |
| `cad_and_blender/openscad/wind/v2.0/*.png` | Full set of 1024x768 isometric and clearance renders |

### E. Historical Baseline Archive (`cad_and_blender/openscad/wind/archive/v1.0/`)
| Source Path | Role |
| :--- | :--- |
| `archive/v1.0/*` | Frozen archive of superseded v1.0 two-phase rocking sail and R1-R3 analytical studies |

---

## 3. Surgical Migration Protocol (Single-Command Execution)

When the decision is made to initialize the dedicated repository, execute:

```bash
# 1. Export entire wind tree into target directory
TARGET_REPO="/path/to/new/arctic-wind-v2"
mkdir -p "$TARGET_REPO"

# 2. Copy core assets
cp -r cad_and_blender/openscad/wind/* "$TARGET_REPO/"
mkdir -p "$TARGET_REPO/scripts"
cp scripts/render_v2_*.sh "$TARGET_REPO/scripts/"
mkdir -p "$TARGET_REPO/docs"
cp docs/release_notes/v1.3.0-draft.md "$TARGET_REPO/docs/README.md"
cp docs/repo_extraction_manifest.md "$TARGET_REPO/docs/"

# 3. Verify numerical suite integrity in destination
cd "$TARGET_REPO/v2.0"
for script in *.py; do
    python3 "$script"
done
```

All 9 Python physics validation suites are verified to run standalone with zero external dependencies.
