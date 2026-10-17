# FreeCAD Parametric CAD & Solid Model Engineering

> **Authoritative Specification:** Single source of truth for all native FreeCAD and CadQuery parametric solid models across `asi.surge.sh`.
> **Governing Standards:** Tracked under Issue [#101](https://github.com/stellardreams/asi.surge.sh/issues/101) in lockstep with Issue [#18](https://github.com/stellardreams/asi.surge.sh/issues/18).

---

## 📂 Directory Architecture

```
cad_and_blender/freecad/
├── README.md                           # Environment setup, headless batch scripts, and navigation guide
├── common/                             # Shared parametric primitives & hardware library
│   ├── fasteners.py                    # ISO metric bolts, pins, clevises, brackets
│   ├── hydraulics.py                   # Parametric double-acting hydraulic ram cylinders
│   └── structural_profiles.py          # A36 I-beams, box tubes, diagrid trusses
├── amu_orbital/                        # Spacecraft manufacturing core & lattice nodes
├── amu_surface/                        # Polar surface infrastructure & transfer portals
├── robotics/                           # CORA-M 7-DoF arms & end-effectors
├── mobility/                           # STRIDER-M heavy tracked rovers & outriggers
├── wind/                               # Modular Arctic wind turbine v2.0 & container
└── step_exports/                       # Headless auto-generated STEP/IGES solid exports
```

> [!NOTE]
> ### 💡 What is a "Solid Model / STEP Export"?
> - **Solid Model (B-Rep Geometry)**: Unlike OpenSCAD which evaluates shapes as polygon meshes (triangulated faceted surfaces via CSG), FreeCAD uses the OpenCASCADE kernel to represent true continuous analytical geometry: exact cylinders, spheres, NURBS surfaces, fillets, and chamfers with mathematical curvature.
> - **STEP (`.step` / `.stp`) Format**: Standard for the Exchange of Product Model Data (ISO 10303). It is the universal standard interchange format for mechanical CAD/CAM/CAE engineering.
> - **Why it Matters for our Repository**:
>   1. **Cross-Platform Interoperability**: STEP files can be opened and verified directly in any major CAD package (FreeCAD, SolidWorks, Autodesk Fusion, Rhino, Onshape) with zero loss of dimensional fidelity.
>   2. **Engineering Simulation**: Enables direct import into Finite Element Analysis (FEA for chassis stress/strain) and Computational Fluid Dynamics (CFD for Arctic wind gusts).
>   3. **Automated Headless Builds**: Headless CI scripts run FreeCAD in background mode to compile Python parametric code directly into `.step` files without needing a display server.

---

## 🖱️ Navigation & Reviewing Models in FreeCAD

### Opening Files in FreeCAD GUI
1. Launch FreeCAD:
   ```bash
   freecad &
   ```
2. Navigate to **File $\to$ Open** (`Ctrl` + `O`).
3. Select any target `.py` parametric script or generated `.step` / `.FCStd` file.
4. When opening a Python parametric script (`.py`), press **Macro $\to$ Execute Macro** (or the green play button ▶️ / `Ctrl` + `F6`) to build the 3D parametric solids into the tree view.

### Viewport Navigation Styles
FreeCAD provides customizable navigation styles (**Preferences $\to$ Display $\to$ Navigation**):

#### 1. CAD Navigation Style (FreeCAD Default):
- **Rotate / Orbit**: Hold **Middle Mouse Button** (scroll wheel), then press and hold **Left Mouse Button** (or Middle + Right), and drag.
- **Pan**: Hold **Middle Mouse Button** and drag.
- **Zoom In / Out**: Scroll mouse wheel up/down, or hold `Shift` + **Right Mouse Button** and drag.

#### 2. OpenSCAD Navigation Style (Selectable in Preferences):
- **Rotate / Orbit**: Hold **Left Mouse Button** and drag.
- **Pan**: Hold **Right Mouse Button** and drag.
- **Zoom In / Out**: Scroll mouse wheel up/down, or hold **Middle Mouse Button** and drag.

### Keyboard Shortcuts
| Action | FreeCAD Keyboard Shortcut | Description |
|:---|:---|:---|
| **Fit All (Zoom to Extents)** | `V` then `F` (or `Space` on selected object) | Fits all visible geometry into screen bounds |
| **Isometric View** | `0` | Standard 3D isometric perspective |
| **Front View** | `1` | XY plane elevation |
| **Top View** | `2` | Horizontal ground plane projection |
| **Right Side View** | `3` | YZ profile view |
| **Wireframe / Shaded** | `V` then `1` / `V` then `2` | Toggle rendering style |
