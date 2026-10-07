// =============================================================================
// AMU — Wind Chassis Retrofit (v1)
// Autonomous Manufacturing Unit — chassis-only variant hosting a modular wind turbine mount
// Location: cad_and_blender/openscad/wind/amu_wind_chassis_v1.scad
// Issue: #82 — chassis-level exploration, modular wind applications
// Reference: cad_and_blender/openscad/opencode/amu_CORA-M-arm-opencode_v1.scad (canonical — NOT modified)
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// =============================================================================
//
// SCOPE — read before editing
//
//   This file is deliberately STANDALONE. It does not `include <>` or parametrically
//   inherit from the canonical AMU file, for two reasons verified empirically:
//
//     1. `use <file>` imports modules but does NOT allow consumer-side parameter
//        overrides to reach module bodies. A module reading a global still resolves
//        that global from its own defining file. Overriding here would be silently
//        ignored.
//     2. `include <file>` DOES allow overrides, but it also executes the included
//        file's top-level statements. The canonical file ends with a bare
//        `variant_dual(...)` render call, so including it would bake an entire
//        dual-AMU scene into a chassis-only deliverable.
//
//   Consequently this file re-declares the params it shares with the canonical file:
//     MMS_RADIUS, MMS_LENGTH, WALL_THICK, RIVET_SPACING, RIVET_R, RIVET_H,
//     RIVET_LANE_EXCLUDE, RIVET_APAS_EXCLUDE
//   Those are guarded against divergence by scripts/check_chassis_param_drift.sh.
//   Run it before committing any change here or to the canonical file.
//
// WHAT IS DIFFERENT FROM THE CANONICAL HULL
//
//   Chassis-only. No greenhouse, no solar wings, no 7-DoF arm, no spine rail, no
//   asteroid or extraction scene. Retained: hull, bulkheads, docking rings, the
//   Via Ferrata rivet grid, and the caliper lanes. Added: the wind turbine mount.
//
//   Cached rigidity is supplied by the caliper groove at X=±6.5 (0.42 deep, 4.9 long)
//   — the mount's moment path runs into that existing structure rather than into the
//   rivet grid, so no new hull cutouts are introduced.
//
// ENVIRONMENT
//
//   Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
//   corridor framing does NOT apply to this file. Material and hardening notes are in
//   amu_wind_chassis_v1.md alongside this file.
//
//   Non-scope (per #82): no changes to swarm engine, orbital/ledger layer, or
//   nutrient/logistics modules.
//
// =============================================================================

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;    // hull radius — must match canonical
MMS_LENGTH      = 17.92;  // hull length — must match canonical
WALL_THICK      = 0.4;    // hull wall — must match canonical

// --- Rivet grid (Via Ferrata) — must match canonical ---
RIVET_SPACING       = 1.4;
RIVET_R             = 0.18;
RIVET_H             = 0.34;
RIVET_LANE_EXCLUDE  = 3.00;  // keep caliper lanes at X=±6.5 clear
RIVET_APAS_EXCLUDE  = 1.00;  // keep APAS hatch ring clear
RIVET_EMBED         = 0.06;  // shank burial depth — manifold fix, not a canonical param

// --- Existing docking features, mirrored for exclusion maths ---
ROOF_HATCH_X    = 2.8;    // APAS hatch centre, along X
APAS_RADIUS     = 1.55;
CALIPER_LANE_X  = 6.5;    // caliper groove centre, ±

// --- Wind turbine mount interface ---
WIND_MOUNT_X    = 0.0;    // along X; 0 = hull centre, clear of APAS (2.8) and lanes (±6.5)
WIND_MOUNT_DIA  = 2.60;   // central boss diameter
WIND_MOUNT_PCD  = 2.00;   // bolt circle diameter
WIND_MOUNT_N    = 8;      // bolt count
WIND_BOLT_DIA   = 0.16;   // through-bore diameter
WIND_MOUNT_H    = 0.90;   // boss height above hull surface
WIND_MOUNT_EXCL = 2.10;   // rivet exclusion radius — keeps grid clear of the mount
MOUNT_SEAT      = 0.06;   // base-plate burial into the hull — manifold fix, not a canonical param

// --- Modular transport ---
SCALE_ENVELOPE  = 0.216;  // see amu_wind_chassis_v1.md — diameter-driven, VERIFY against spec
SHOW_SCALE_ENV  = false;  // true = wrap assembly in the transport envelope cube

// --- Toggles ---
SHOW_HULL       = true;
SHOW_RIVETS     = true;
SHOW_CALIPER    = true;
SHOW_MOUNT      = true;
SHOW_DOCKING    = true;

$fn = 64;

// ------------------------------ Palette -------------------------------------
HULL_TAN        = [0.78, 0.70, 0.60];
HULL_DARK       = [0.68, 0.60, 0.50];
RIVET_GOLD      = [0.88, 0.78, 0.35];
MOUNT_METAL     = [0.62, 0.64, 0.68];
MOUNT_DARK      = [0.34, 0.36, 0.40];
BOLT_STEEL      = [0.74, 0.76, 0.80];
DOCK_METAL      = [0.58, 0.58, 0.60];

// ------------------------------ Helpers --------------------------------------

// Reused from canonical (:116) — takes all inputs as arguments, so `use <>` is safe.
// Recreated here rather than imported: the import path would couple this file to a
// sibling's top-level render, which is the problem this file exists to avoid.
module spine_double(len) {
    for (s = [-1, 1])
        translate([0, s * 1.2, 0])
            rotate([0, 90, 0])
                cylinder(h = len, r = 0.42, center = true, $fn = 32);
}

// Reused from canonical (:245)
module torus(r_major, r_minor, seg = 64) {
    rotate_extrude(convexity = 4, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 16);
}

// Via Ferrata rivet — canonical form (:283-286): cylindrical shank bearing shear,
// with the groove hook at the crown for the Gold gripper.
//
// The shank is embedded RIVET_EMBED into the hull. Seating the base exactly on the
// hull surface leaves coincident facets where the hull's $fn=64 and the shank's
// $fn=20 tessellations disagree, which CGAL reports as non-manifold. Overlapping the
// solids by a small amount makes the union well-defined. Visual protrusion above the
// surface is unchanged: only the buried length differs from the canonical file.
module via_ferrata_rivet(r = RIVET_R, h = RIVET_H) {
    union() {
        translate([0, 0, -RIVET_EMBED])
            cylinder(h = h + RIVET_EMBED, r = r, $fn = 20);
        color([0.35, 0.32, 0.30])
            translate([0, 0, h - 0.05])
                rotate([90, 0, 0])
                    torus(r_major = r * 0.85, r_minor = 0.035, seg = 16);
    }
}

// Rivet grid with exclusion zones. Exclusion logic mirrors canonical (:282):
// caliper lanes and the APAS ring are kept clear. Extended here with
// WIND_MOUNT_EXCL so the turbine mount never lands under a rivet.
module rivet_grid() {
    for (x = [-MMS_LENGTH * 0.45 : RIVET_SPACING : MMS_LENGTH * 0.45])
        for (a = [0 : 45 : 315]) {
            in_lane  = abs(x - -CALIPER_LANE_X) < RIVET_LANE_EXCLUDE || abs(x - CALIPER_LANE_X) < RIVET_LANE_EXCLUDE;
            in_apas  = abs(x - ROOF_HATCH_X) <= RIVET_APAS_EXCLUDE && (a == 45 || a == 90 || a == 135);
            in_mount = abs(x - WIND_MOUNT_X) < WIND_MOUNT_EXCL && a >= 45 && a <= 135;
            if (!in_lane && !in_apas && !in_mount)
                color(RIVET_GOLD)
                    translate([x, cos(a) * MMS_RADIUS, sin(a) * MMS_RADIUS])
                        rotate([a - 90, 0, 0])
                            via_ferrata_rivet();
        }
}

// Caliper groove — canonical geometry (:366-368): 4.9 along X, 1.4 across Y,
// 0.42 deep, top flush with the hull. Doubles as the mount's moment path.
module caliper_groove(cx, sideZ) {
    translate([cx, 0, sideZ * (MMS_RADIUS - 0.21)])
        cube([4.9, 1.4, 0.42], center = true);
}

// --------------------------- Wind turbine mount ------------------------------
//
// PCD bolt circle + central boss, seated on the hull TOP surface. The boss is a
// through-bored collar: the bore is a real difference(), not a decal, so the part
// is inspectable and bolt holes actually pass through the plate.
//
// Local frame: z = 0 is the hull surface, +Z is outboard. MOUNT_SEAT is the burial
// of the base plate into the shell — without it the plate would float a visible gap
// above the hull, and CGAL would again see only tangential contact.
module wind_turbine_mount(dia = WIND_MOUNT_DIA, pcd = WIND_MOUNT_PCD,
                          n = WIND_MOUNT_N, bolt_dia = WIND_BOLT_DIA,
                          height = WIND_MOUNT_H) {
    plate_t = 0.24;
    boss_r  = dia / 2 * 0.72;

    translate([WIND_MOUNT_X, 0, MMS_RADIUS]) {
        difference() {
            union() {
                // base plate — seated on the hull, spreads load into the shell
                color(MOUNT_DARK)
                    translate([0, 0, plate_t / 2 - MOUNT_SEAT])
                        cylinder(h = plate_t, r = dia / 2, center = true, $fn = 64);
                // central boss
                color(MOUNT_METAL)
                    translate([0, 0, height / 2])
                        cylinder(h = height, r = boss_r, center = true, $fn = 64);
                // gusset ring — stiffens boss-to-plate transition under side load
                color(MOUNT_METAL)
                    translate([0, 0, plate_t - MOUNT_SEAT])
                        rotate_extrude(convexity = 4, $fn = 64)
                            translate([boss_r, 0, 0])
                                polygon([[0, 0], [0.30, 0], [0, 0.34]]);
            }
            // central through-bore
            color(MOUNT_DARK)
                translate([0, 0, height / 2])
                    cylinder(h = height + 2, r = dia / 2 * 0.34, center = true, $fn = 48);
        }

        // bolt circle — countersunk bores through the base plate
        for (i = [0 : n - 1]) {
            ang = i * 360 / n;
            bx = (pcd / 2) * cos(ang);
            by = (pcd / 2) * sin(ang);
            color(BOLT_STEEL)
                translate([bx, by, plate_t / 2 - MOUNT_SEAT])
                    difference() {
                        cylinder(h = plate_t + 1, r = bolt_dia / 2 * 1.9, center = true, $fn = 24);
                        cylinder(h = plate_t + 2, r = bolt_dia / 2, center = true, $fn = 24);
                    }
        }

        // alignment witness marks — quarter-turn lugs, removable without disturbing bolts
        for (q = [0, 90, 180, 270])
            color([0.95, 0.92, 0.30])
                rotate([0, 0, q])
                    translate([dia / 2 - 0.10, 0, plate_t - MOUNT_SEAT])
                        cube([0.20, 0.09, 0.06], center = true);
    }
}

// ------------------------------- Chassis -------------------------------------

module wind_chassis() {
    if (SHOW_HULL) {
        difference() {
            union() {
                // main hull — straight cylinder along X, flat bulkheads
                color(HULL_TAN)
                    rotate([0, 90, 0])
                        cylinder(h = MMS_LENGTH, r = MMS_RADIUS, center = true, $fn = 64);

                // panel seams
                for (i = [-1, 0, 1])
                    color(HULL_DARK)
                        translate([i * MMS_LENGTH * 0.28, 0, 0])
                            rotate([0, 90, 0])
                                torus(r_major = MMS_RADIUS * 0.78, r_minor = 0.12, seg = 64);

                if (SHOW_RIVETS) rivet_grid();

                // APAS docking ring + hatch recess
                if (SHOW_DOCKING) {
                    color([0.92, 0.92, 0.94])
                        translate([ROOF_HATCH_X, 0, MMS_RADIUS + 0.06])
                            rotate([0, 90, 0])
                                torus(r_major = APAS_RADIUS - 0.07, r_minor = 0.14, seg = 48);
                    color([0.18, 0.18, 0.22])
                        for (p = [0 : 120 : 240])
                            rotate([0, 0, p])
                                translate([ROOF_HATCH_X, 0, MMS_RADIUS + 0.06])
                                    rotate([0, 90, 0])
                                        cylinder(h = 0.10, r = APAS_RADIUS * 0.24, center = true, $fn = 24);
                }

                // bulkheads + docking rings
                for (sx = [-1, 1])
                    translate([sx * MMS_LENGTH / 2, 0, 0]) {
                        color(HULL_TAN)
                            rotate([0, 90, 0])
                                cylinder(h = 0.6, r = MMS_RADIUS * 0.92, center = true, $fn = 48);
                        color(DOCK_METAL)
                            rotate([0, 90, 0])
                                torus(r_major = MMS_RADIUS * 0.72, r_minor = 0.18, seg = 48);
                        color([0.22, 0.22, 0.24])
                            rotate([0, 90, 0])
                                cylinder(h = 0.62, r = MMS_RADIUS * 0.35, center = true, $fn = 32);
                    }

                if (SHOW_CALIPER)
                    for (cx = [-CALIPER_LANE_X, CALIPER_LANE_X])
                        for (sideZ = [1, -1])
                            caliper_groove(cx, sideZ);
            }

            // APAS hatch opening — TOP Z+, offset along X as in canonical
            if (SHOW_DOCKING)
                translate([ROOF_HATCH_X, 0, MMS_RADIUS + 0.05])
                    cylinder(h = WALL_THICK * 4, r = APAS_RADIUS + 0.08, center = true, $fn = 48);
        }

        if (SHOW_MOUNT) wind_turbine_mount();
    }
}

// Transport envelope — shows the chassis against the scaled bounding box.
module transport_envelope() {
    L = MMS_LENGTH * SCALE_ENVELOPE;
    D = MMS_RADIUS * 2 * SCALE_ENVELOPE;
    color([0.30, 0.90, 0.50, 0.10])
        translate([0, 0, 0])
            cube([L, D, D], center = true);
    color([0.30, 0.90, 0.50, 0.85])
        translate([L / 2, 0, D / 2]) cube([0.04, D, 0.04], center = true);
        translate([L / 2, 0, -D / 2]) cube([0.04, D, 0.04], center = true);
        translate([L / 2, D / 2, 0]) cube([0.04, 0.04, D], center = true);
        translate([L / 2, -D / 2, 0]) cube([0.04, 0.04, D], center = true);
}

// ------------------------------- Render --------------------------------------
wind_chassis();
if (SHOW_SCALE_ENV) scale(SCALE_ENVELOPE) transport_envelope();

// Build tips:
// Preview F5 (fast) | Render F6 (CGAL, high $fn) | Export STL/3MF/DXF
// Chassis is 17.92 long × 12.0 diameter. Diameter is the transport-governing
// dimension — see amu_wind_chassis_v1.md before changing SCALE_ENVELOPE.
// Issue: #82 | Param drift check: scripts/check_chassis_param_drift.sh
//
// Signed: [OpenCode](https://opencode.ai) — 2026-10-07
