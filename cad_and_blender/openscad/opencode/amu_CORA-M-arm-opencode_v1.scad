// =============================================================================
// AMU CORA-M — Common Omni-purpose Robotic Attachment (Mobile) on AMU (OpenCode v1.4 — Realistic)
// AMU — Autonomous Manufacturing Unit | CORA-M — Common Omni-purpose Robotic Attachment (Mobile)
// Awakened Imagination Group — TRL 1 parametric sketch
// Location: cad_and_blender/openscad/opencode/amu_CORA-M-arm-opencode_v1.scad
// Note: AMU CORA-M (Mobile) stands for Common Omni-purpose Robotic Attachment — rail-mounted 7-DoF arm with graspable rivets for surface locomotion
// Source visuals ingested 2026-09-16 (realistic color-matched):
//   - Renders: Manufacturing Units (tan hull #C8B8A0, black solar #0A0A0F, blue arm #1A6FFF, spine #D0D0D0)
//              Orbiting Greenhouses (transparent hull α0.35, shelves #E0E0E0, sprouts #4A8A4A, cyan beams #4DFFF0)
//              Heritage Greenhouses (warm interior #FFF8EC, soil #5A3A28, leaf #2E7D32)
//   - Video 1: amu-animation-v1.mp4 (asteroid #6E6E72 cratered, Resource Hub teal glow, Orbital Sentry grey)
//   - Video 2: heritage_greenhouse_animation-v1.mp4 (arched glass + central aisle, robots #F0F0F0)
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// Realism note: OpenSCAD is CSG-only — true PBR/textures require Blender (see blender_including_blender_python/generate_amu.py:22)
//              This file pushes OpenSCAD realism to its limit via $fn=64, accurate PBR colors, and micro-details.
// Branch: main-dev → master (see docs/release_notes/v1.1.md:1)
// =============================================================================

// ---------------------------- Realistic palette (PBR) ------------------------
HULL_TAN        = [0.78, 0.70, 0.60]; // tan hull as in Manufacturing Units
HULL_DARK       = [0.68, 0.60, 0.50]; // panel seam
SOLAR_BLACK     = [0.04, 0.04, 0.07]; // solar near-black
SOLAR_GRID      = [0.18, 0.22, 0.45]; // grid line blue
SPINE_METAL     = [0.82, 0.82, 0.84]; // anodized aluminium
ARM_BLUE        = [0.12, 0.45, 0.85]; // heritage Z-arm
BEAM_CYAN       = [0.30, 0.96, 0.96]; // extraction laser
BEAM_GLOW       = [0.45, 1.00, 1.00, 0.22];
ASTEROID_GREY   = [0.44, 0.44, 0.46];
SHELF_ALU       = [0.88, 0.88, 0.89];
SPROUT_GREEN    = [0.30, 0.68, 0.32];
SOIL_BROWN      = [0.36, 0.25, 0.18];

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;
MMS_LENGTH      = 17.92; // was 14.0, +14% per side (28% total) per feedback
CORE_RADIUS     = 0.18;
SPINE_LENGTH    = 30.0;
WALL_THICK      = 0.4;

LOGI_RADIUS     = 3.4;
LOGI_LENGTH     = 9.0;
LOGI_OFFSET     = 11.0;

DOOR_W          = 2.2;
DOOR_H          = 2.2;
DOOR_EDGE       = 3.5;
DOOR_FRAME_THICK= 0.18; // realistic frame
BELLY_DOOR_W    = 5.0;  // belly cargo door (ventral, for rail goods)
BELLY_DOOR_L    = 3.2;  // along X
BELLY_DOOR_Y    = -1;   // side: -1 ventral / +1 dorsal

// --- STS-132 Atlantis docking port (ISS APAS/PMA-2) — top Z+ circular hatch ---
ROOF_HATCH_L    = 8.0;  // legacy shuttle bay L (kept for compat, not used for APAS)
ROOF_HATCH_W    = 5.0;  // legacy shuttle bay W (kept for compat)
ROOF_HATCH_ANGLE= 155;  // legacy shuttle angle (kept)
ROOF_HATCH_X    = 2.8;  // offset from hull center along X — between middle (0) & side bulkhead (≈8.96)
SHOW_ROOF_HATCH = true; // dorsal roof — now Atlantis APAS docking hatch at top Z+ (STS-132)
APAS_RADIUS     = 1.55; // APAS/PMA-2 ring radius — as Atlantis docked to Harmony forward (wiki STS-132 main image)
APAS_RING_TUBE  = 0.14; // torus tube
APAS_HATCH_R    = 1.22; // inner pressure hatch radius
APAS_HATCH_ANGLE= 115;  // open outward (hinged) when ROOF_HATCH_OPEN=true
APAS_PETAL_H    = 0.38; // guide petal height
DOCK_COLOR_RING = [0.92,0.92,0.94]; // white ring
DOCK_COLOR_PETAL= [0.18,0.18,0.22]; // dark petal base

BAY_COUNT       = 3;
BAY_RADIUS      = 1.1;
BAY_LENGTH      = 6.0;

FRAME_SPAN      = 10.0;
FRAME_THICK     = 0.6;
MODULE_SIZE     = 4.0;

SOLAR_W         = 7.0;
SOLAR_H         = 3.5;
SOLAR_GAP       = 1.2;
SOLAR_OFFSET    = 9.0;
SOLAR_CELL_GAP  = 0.35; // grid
SOLAR_ANGLE     = 0;    // flat ISS — 0 for flat, 8 for dynamic taper hint

GH_TIERS        = 8;
GH_SHELF_THICK  = 0.15;
GH_SPROUT_R     = 0.08;

ASTEROID_R      = 12.0;
BEAM_R          = 0.12;

SHOW_HULL       = true;
SHOW_SPINE      = true;   // now ventral, outside hull — not through middle
SHOW_SOLAR      = true;
SHOW_DOOR       = true;
SHOW_BELLY_DOOR = true;   // ventral belly cargo doors for rail (kept as-is)
SHOW_GH         = true;
SHOW_ARM        = true;
SHOW_DAUGHTER   = true;
SHOW_TRANSPARENT= true;
SHOW_BEAMS      = true;
ROOF_HATCH_OPEN = true;   // true=Shuttle open (155° clamshell), false=closed flush
HATCH_HINGE_SIDE= 1;       // legacy single-hinge compat (unused for shuttle dual doors)

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine_double(len) {
    // transport rail — E-W, slightly out from hull center (Y=1.2) for visibility between AMUs
    y_out = 1.2; // out a little bit per feedback
    for (dz = [-0.6, 0.6])
        translate([0, y_out, dz])
            rotate([0, 90, 0])
                color(SPINE_METAL) cylinder(h = len, r = 0.42, center = true, $fn = 18);
    // ties every 5
    for (x = [-len/2 + 2 : 5 : len/2 - 2])
        translate([x, y_out, 0])
            color([0.45,0.45,0.48]) cube([0.4, 1.8, 0.18], center = true);
    // carriers
    for (x = [-len*0.25, 0, len*0.25])
        translate([x, y_out, 0.85])
            color(ARM_BLUE) cube([0.9, 0.9, 0.55], center = true);
    // end clamps at bulkheads
    for (x = [-len/2, len/2])
        translate([x, y_out, 0]) {
            color([0.55,0.55,0.58]) cylinder(h = 0.5, r = 0.75, center = true, $fn = 16);
            color([0.30,0.30,0.33]) cube([0.6, 1.4, 0.6], center = true);
        }
}

// --- 7-DoF Rail-Mounted Arm from Issue 5 sample (APAS hatch vicinity) — scaled to AMU units ---
// Sample: rail 500mm, carriage 60mm, 7 joints — scaled 0.015≈500->7.5 units to fit MMS_LENGTH 17.92, placed at TOP Z+ near APAS
_APAS_arm_scale = 0.014; // sample mm -> AMU units (tuned: 500*0.014=7.0, arm reach ~4.5 to reach hatch at Z=6)
_APAS_rail_len = 500 * _APAS_arm_scale;
_APAS_rail_w = 40 * _APAS_arm_scale;
_APAS_rail_t = 15 * _APAS_arm_scale;
_APAS_j2 = 25; _APAS_j3 = -30; _APAS_j4 = 45; _APAS_j5 = -60; _APAS_j6 = 15; _APAS_j7 = 30; _APAS_j8 = 90;

module apas_arm_seg(len, r1, r2, col) {
    color(col) {
        cylinder(h=len, r1=r1, r2=r2, $fn=24);
        sphere(r=r1, $fn=16);
        translate([0,0,len]) sphere(r=r2, $fn=16);
    }
}
module apas_arm_rail() {
    color([0.18,0.22,0.26]) cube([_APAS_rail_len, _APAS_rail_w, _APAS_rail_t], center=true);
    color([0.75,0.75,0.78]) {
        translate([0, -(_APAS_rail_w/2 - 4*_APAS_arm_scale), _APAS_rail_t/2]) rotate([0,90,0]) cylinder(h=_APAS_rail_len, r=3*_APAS_arm_scale, center=true, $fn=16);
        translate([0,  (_APAS_rail_w/2 - 4*_APAS_arm_scale), _APAS_rail_t/2]) rotate([0,90,0]) cylinder(h=_APAS_rail_len, r=3*_APAS_arm_scale, center=true, $fn=16);
    }
}
module apas_arm_carriage() {
    color([0.73,0.80,0.88]) cube([60*_APAS_arm_scale, _APAS_rail_w+10*_APAS_arm_scale, _APAS_rail_t+8*_APAS_arm_scale], center=true);
    color([0.33,0.33,0.37]) translate([0,0,(_APAS_rail_t+8*_APAS_arm_scale)/2 + 5*_APAS_arm_scale]) cube([40*_APAS_arm_scale,30*_APAS_arm_scale,10*_APAS_arm_scale], center=true);
}
module apas_7dof_arm() {
    s = _APAS_arm_scale;
    rotate([0,0,_APAS_j2]) {
        apas_arm_seg(30*s,18*s,16*s,"CadetBlue");
        translate([0,0,30*s]) rotate([0,_APAS_j3,0]) {
            apas_arm_seg(120*s,16*s,12*s,"WhiteSmoke");
            translate([0,0,120*s]) rotate([0,0,_APAS_j4]) {
                apas_arm_seg(25*s,12*s,12*s,"CadetBlue");
                translate([0,0,25*s]) rotate([0,_APAS_j5,0]) {
                    apas_arm_seg(100*s,12*s,10*s,"WhiteSmoke");
                    translate([0,0,100*s]) rotate([0,0,_APAS_j6]) {
                        apas_arm_seg(20*s,10*s,10*s,"CadetBlue");
                        translate([0,0,20*s]) rotate([0,_APAS_j7,0]) {
                            apas_arm_seg(15*s,10*s,8*s,"LightGray");
                            translate([0,0,15*s]) rotate([0,0,_APAS_j8]) {
                                color("Gold") {
                                    cylinder(h=10*s,r1=8*s,r2=4*s,$fn=24);
                                    translate([-5*s,0,10*s]) cube([2*s,6*s,12*s]);
                                    translate([3*s,0,10*s]) cube([2*s,6*s,12*s]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
module apas_arm_near_hatch() {
    // Rail along X at TOP Z+ EXTERIOR — moved outside hull so visible (was interior Z=1.4)
    // Pulled near APAS hatch at ROOF_HATCH_X, Z=MMS_RADIUS+0.6 exterior top, per request to see it
    translate([ROOF_HATCH_X, 0, MMS_RADIUS + 0.65]) {
        apas_arm_rail();
        // Joint 1: carriage along X — place at 65% along rail toward hatch center so arm base is under opening
        translate([0.18*_APAS_rail_len, 0, 0]) {
            apas_arm_carriage();
            translate([0,0,(_APAS_rail_t+8*_APAS_arm_scale)/2 + 10*_APAS_arm_scale]) {
                // Yaw the arm toward hatch opening (+Z) and slightly toward center
                rotate([0,0, -12])
                    apas_7dof_arm();
            }
        }
    }
}

// CORA-M locomotion demo path — hand-over-hand crawl waypoints on cylindrical rivets for Space ROS/Gazebo
// Waypoints are rivet positions [X, angle] that Gold gripper can grasp to move around body — track in Issue 5
CORA_PATH = [ [-6.8, 0], [-3.8, 60], [-0.8, 300], [2.2, 60], [5.2, 0] ]; // X along hull, a around 60°
SHOW_CORA_PATH = false; // toggle path visualization — disabled per feedback (keep modules, no preview)
module cora_locomotion_path() {
    for (i = [0 : len(CORA_PATH)-1]) {
        x = CORA_PATH[i][0]; a = CORA_PATH[i][1];
        // waypoint marker at rivet tip
        color(i==0 ? [0.92,0.72,0.15] : [0.15,0.72,0.92])
            translate([x, cos(a)*(MMS_RADIUS+0.32), sin(a)*(MMS_RADIUS+0.32)]) sphere(r=0.14, $fn=16);
        // tether line between waypoints
        if (i < len(CORA_PATH)-1) {
            x2 = CORA_PATH[i+1][0]; a2 = CORA_PATH[i+1][1];
            color([0.95,0.85,0.15,0.35])
                hull() {
                    translate([x, cos(a)*(MMS_RADIUS+0.32), sin(a)*(MMS_RADIUS+0.32)]) sphere(r=0.03,$fn=8);
                    translate([x2, cos(a2)*(MMS_RADIUS+0.32), sin(a2)*(MMS_RADIUS+0.32)]) sphere(r=0.03,$fn=8);
                }
        }
        // label index
        // color([1,1,1]) translate([x, cos(a)*(MMS_RADIUS+0.55), sin(a)*(MMS_RADIUS+0.55)]) text(str(i), size=0.5);
    }
}
module cora_locomotion_preview(step=0) {
    // ghost arm at waypoint step — shows CORA-M reaching to grasp rivet (for F5 scrub, Space ROS import)
    // step 0..len(CORA_PATH)-1, wrap
    s = step % len(CORA_PATH);
    x = CORA_PATH[s][0]; a = CORA_PATH[s][1];
    // place rail exterior near that rivet, oriented tangentially (rail along X)
    translate([x, cos(a)*(MMS_RADIUS+0.65), sin(a)*(MMS_RADIUS+0.65)]) {
        // small rail segment at this station (ghost)
        % color([0.60,0.60,0.65,0.35]) apas_arm_rail();
        translate([0.10*_APAS_rail_len, 0, 0]) {
            % apas_arm_carriage();
            translate([0,0,(_APAS_rail_t+8*_APAS_arm_scale)/2 + 10*_APAS_arm_scale])
                rotate([a,0,0]) // orient arm toward hull
                    apas_7dof_arm();
        }
    }
    // highlight active rivet
    color([1,0.3,0.3]) translate([x, cos(a)*(MMS_RADIUS+0.32), sin(a)*(MMS_RADIUS+0.32)]) sphere(r=0.20,$fn=16);
}

module torus(r_major, r_minor, seg = 64) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 32);
}

module mms_hull_realistic(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN, roof_ang = ROOF_HATCH_ANGLE) {
    difference() {
        union() {
            // main hull — straight cylinder, flat bulkheads — heritage exterior
            color(HULL_TAN)
                rotate([0, 90, 0])
                    cylinder(h = MMS_LENGTH, r = MMS_RADIUS, center = true, $fn = 64);
            // flat bulkheads + docking rings
            for (sx = [-1, 1]) {
                translate([sx * MMS_LENGTH/2, 0, 0]) {
                    color(HULL_TAN) rotate([0, 90, 0]) cylinder(h = 0.6, r = MMS_RADIUS*0.92, center = true, $fn = 48);
                    color([0.58,0.58,0.60]) rotate([0, 90, 0]) torus(r_major = MMS_RADIUS*0.72, r_minor = 0.18, seg = 48);
                    color([0.22,0.22,0.24]) rotate([0, 90, 0]) cylinder(h = 0.62, r = MMS_RADIUS*0.35, center = true, $fn = 32);
                }
            }
            // panel seams
            for (i = [-1, 0, 1])
                translate([i * MMS_LENGTH*0.28, 0, 0])
                    rotate([0, 90, 0])
                        color(HULL_DARK) torus(r_major = MMS_RADIUS*0.78, r_minor = 0.12, seg = 64);
            // rivet row (cosmetic)
            for (i = [-1:0.5:1]) for (a = [0:60:300])
                translate([i * MMS_LENGTH*0.32, cos(a)*MMS_RADIUS*0.83, sin(a)*MMS_RADIUS*0.83])
                    color([0.52,0.48,0.42]) sphere(r = 0.07, $fn = 8);
            // graspable cylindrical rivets — SAME DIMENSION pure cylinder throughout hull for CORA-M locomotion
            // Pure uniform: r=0.16 h=0.32 protruding along normal — no cap, no taper, no narrow neck, no top shape — full shank bears shear
            // Robot Gold gripper grasps full cylinder identically; pure shear, strongest under moment
            // 1x caliper lane: X<-4.5, a==0 (Y+ rail corridor where towing vehicles dock) — NO rivets there
            for (x = [-MMS_LENGTH*0.38 : 3.0 : MMS_LENGTH*0.38])
                for (a = [0:60:300]) {
                    if ((abs(x - ROOF_HATCH_X) > 1.6 || !(a == 90 || a == 60)) && !(x < -4.5 && a == 0)) {
                        color([0.52,0.48,0.44])
                            translate([x, cos(a)*MMS_RADIUS, sin(a)*MMS_RADIUS])
                                rotate([a-90,0,0])
                                    cylinder(h=0.32, r=0.16, $fn=20);
                    }
                }
            // 1x caliper lane highlight — where towing vehicles dock from SIDE (Y+ rail corridor, X<-4.5, no rivets) — POP with high contrast
            // outer glow for pop
            color([1,1,1,0.22])
                translate([(-8.96 + -4.5)/2, MMS_RADIUS+0.11, 0])
                    cube([5.0, 0.10, 2.1], center=true);
            color([0.00, 0.52, 1.00, 0.82])
                translate([(-8.96 + -4.5)/2, MMS_RADIUS+0.10, 0])
                    cube([4.9, 0.08, 2.0], center=true);
            color([1.00, 0.88, 0.00, 0.95])
                translate([(-8.96 + -4.5)/2, MMS_RADIUS+0.16, 0])
                    cube([4.7, 0.035, 0.14], center=true);
            // dashed centerline along lane — high contrast white
            for (x = [-8.6 : 0.9 : -4.9])
                color([1,1,1,0.98])
                    translate([x, MMS_RADIUS+0.17, 0]) cube([0.48, 0.018, 0.018], center=true);
            // additional spine cylindrical rivets on TOP Z+ — same pure cylinder
            for (x = [-MMS_LENGTH*0.45 : 4.2 : MMS_LENGTH*0.45])
                translate([x, 0, MMS_RADIUS])
                    color([0.52,0.48,0.44])
                        cylinder(h=0.32, r=0.16, $fn=20);
        }
        // side door cavities (as before)
        if (SHOW_DOOR) {
            for (sx = [-1, 1])
                translate([sx * (MMS_LENGTH/2 - DOOR_EDGE), -MMS_RADIUS*0.55, MMS_RADIUS*0.45]) {
                    cube([DOOR_W, DOOR_H, WALL_THICK*4], center = true);
                }
        }
        // belly cargo doors — ventral, for rail
        // outer entrances remain closed, inner facing where AMUs face each other are open and rail-connected
        if (SHOW_BELLY_DOOR) {
            if (open_left_belly)
                translate([-3.0, -MMS_RADIUS - 0.05, 0])
                    cube([BELLY_DOOR_W, WALL_THICK*4, BELLY_DOOR_L], center = true);
            if (open_right_belly)
                translate([ 3.0, -MMS_RADIUS - 0.05, 0])
                    cube([BELLY_DOOR_W, WALL_THICK*4, BELLY_DOOR_L], center = true);
        }
        // STS-132 Atlantis docking port opening — circular cut at TOP Z+ (like Atlantis at ISS PMA-2 Harmony forward)
        // kept separate from belly doors (Y- ventral); offset ROOF_HATCH_X between middle & bulkhead; TOP is Z+
        if (SHOW_ROOF_HATCH) {
            translate([ROOF_HATCH_X, 0, MMS_RADIUS + 0.05])
                cylinder(h = WALL_THICK*4, r = APAS_RADIUS + 0.08, center = true, $fn=48);
        }
        // 1x caliper lane DEPRESSION at SIDE Y+ (where towing vehicles dock from side) — recess so calipers fit
        // Groove along X (4.9), width Z (1.4), depth Y (0.42) into hull — top flush at MMS_RADIUS, bottom recessed — no rivets here, caliper jaws seat in groove
        translate([(-8.96 + -4.5)/2, MMS_RADIUS - 0.21, 0])
            cube([4.9, 0.42, 1.4], center = true);
    }
    // belly door frames — only for open doors; closed outer doors show as solid hatch
    if (SHOW_BELLY_DOOR) {
        for (sx = [-1, 1]) {
            is_open = (sx == -1) ? open_left_belly : open_right_belly;
            translate([sx * 3.0, -MMS_RADIUS + 0.22, 0])
                color(is_open ? HULL_DARK : [0.42,0.38,0.34]) // closed outer = solid tan darker
                    cube([BELLY_DOOR_W+0.4, 0.25, BELLY_DOOR_L+0.4], center = true);
            if (is_open)
                translate([sx * 3.0, -MMS_RADIUS + 0.12, 0])
                    color([0.25,0.25,0.28]) cube([BELLY_DOOR_W*0.88, 0.26, 0.06], center = true);
            else
                translate([sx * 3.0, -MMS_RADIUS + 0.18, 0])
                    color([0.35,0.32,0.30]) cube([BELLY_DOOR_W*0.7, 0.27, BELLY_DOOR_L*0.7], center = true); // closed hatch fill
        }
    }
    // dorsal roof — STS-132 Atlantis docking port (ISS PMA-2/APAS-95) at TOP Z+ — circular hatch as Atlantis docks to ISS
    // Based on STS-132 main image: Atlantis docked to Harmony forward PMA-2, white ring with 3 petals — https://en.wikipedia.org/wiki/STS-132
    // Offset ROOF_HATCH_X between middle (0) & bulkhead (≈8.96); TOP is Z+ so greenhouse tiers (along Z) exposed when open; belly entrances stay Y- ventral
    if (SHOW_ROOF_HATCH) {
        ang = roof_open ? roof_ang : 0;
        cx = ROOF_HATCH_X; cy = 0; cz = MMS_RADIUS;
        // outer base flange (tan, hull-blended) + dark coaming
        color(HULL_TAN)
            translate([cx, cy, cz + 0.10])
                cylinder(h = 0.22, r = APAS_RADIUS + 0.42, center = true, $fn = 48);
        color(HULL_DARK)
            translate([cx, cy, cz + 0.20])
                difference() {
                    cylinder(h = 0.08, r = APAS_RADIUS + 0.45, center = true, $fn = 48);
                    cylinder(h = 0.10, r = APAS_RADIUS + 0.08, center = true, $fn = 48);
                }
        // soft capture seal (dark)
        color([0.22,0.22,0.24])
            translate([cx, cy, cz + 0.24])
                difference() {
                    cylinder(h = 0.05, r = APAS_RADIUS + 0.12, center = true, $fn = 48);
                    cylinder(h = 0.07, r = APAS_RADIUS - 0.10, center = true, $fn = 48);
                }
        // main APAS white docking ring (androgynous, PMA-2) — white as in STS-132 image
        color(DOCK_COLOR_RING)
            translate([cx, cy, cz + 0.30])
                difference() {
                    cylinder(h = 0.18, r = APAS_RADIUS + 0.02, center = true, $fn = 48);
                    cylinder(h = 0.20, r = APAS_RADIUS - 0.14, center = true, $fn = 48);
                }
        // inner bevel ring (aluminium)
        color([0.82,0.82,0.84])
            translate([cx, cy, cz + 0.33])
                rotate_extrude(convexity=10,$fn=48) translate([APAS_RADIUS - 0.07,0,0]) circle(r=0.04,$fn=16);
        // 3 guide petals at 120° (APAS capture petals) — iconic 3-petal star as Atlantis approaches ISS
        for (a = [0, 120, 240]) {
            translate([cx, cy, cz + 0.38])
                rotate([0, 0, a])
                    translate([APAS_RADIUS*0.86, 0, 0]) {
                        color(DOCK_COLOR_PETAL)
                            translate([0.06, 0, 0.08])
                                rotate([0, 28, 0])
                                    cube([0.04, 0.62, APAS_PETAL_H], center = true);
                        color(DOCK_COLOR_RING)
                            translate([0.09, 0, 0.22])
                                rotate([0, 28, 0])
                                    cube([0.03, 0.60, 0.18], center = true);
                        color([0.88,0.72,0.15])
                            translate([0.12, 0, 0.38]) sphere(r=0.04,$fn=8);
                    }
        }
        // 12x peripheral latches around ring (evenly spaced)
        for (a = [0:30:330])
            translate([cx + cos(a)*APAS_RADIUS*0.98, sin(a)*APAS_RADIUS*0.98, cz+0.30])
                color([0.55,0.55,0.58]) cube([0.12, 0.06, 0.06], center=true);
        // inner pressure hatch — circular, hinged at +Y edge, opens outward like ISS Node hatch (STS-132)
        hinge_y = APAS_RADIUS + 0.12;
        translate([cx, hinge_y, cz + 0.18]) {
            rotate([-ang, 0, 0])
                translate([0, -APAS_RADIUS, 0]) {
                    // hatch plate (tan outside, white inside as shuttle/ISS)
                    color(HULL_TAN)
                        translate([0, 0, 0.04])
                            cylinder(h = 0.14, r = APAS_HATCH_R + 0.06, center = true, $fn = 48);
                    color([0.94,0.94,0.96])
                        translate([0, 0, 0.11])
                            cylinder(h = 0.02, r = APAS_HATCH_R, center = true, $fn = 48);
                    // radial stiffeners (6 spokes like ISS hatch)
                    for (a = [0:60:300])
                        rotate([0,0,a])
                            color([0.70,0.68,0.65])
                                translate([APAS_HATCH_R*0.52, 0, 0.13])
                                    cube([APAS_HATCH_R*0.88, 0.07, 0.03], center=true);
                    // central wheel handle (ISS hatch wheel)
                    color([0.88,0.88,0.90])
                        translate([0, 0, 0.15])
                            torus(r_major = 0.28, r_minor = 0.035, seg=32);
                    color([0.35,0.35,0.38])
                        translate([0, 0, 0.15])
                            cylinder(h=0.05, r=0.07, center=true, $fn=16);
                    // 4 latches around hatch rim
                    for (a = [45,135,225,315])
                        rotate([0,0,a])
                            translate([APAS_HATCH_R*0.88, 0, 0.13])
                                color([0.92,0.92,0.96]) cube([0.18,0.07,0.05], center=true);
                    // small viewport window in hatch (circular, like ISS)
                    color([0.55,0.75,0.95,0.65])
                        translate([0, APAS_HATCH_R*0.32, 0.14]) cylinder(h=0.025, r=0.22, center=true, $fn=24);
                    color([0.30,0.30,0.33])
                        translate([0, APAS_HATCH_R*0.32, 0.14])
                            difference() {
                                cylinder(h=0.02, r=0.24, center=true, $fn=24);
                                cylinder(h=0.025, r=0.22, center=true, $fn=24);
                            }
                }
            // hinge barrels (2, like ISS hatch hinge, stay on hull)
            for (hx = [-0.32, 0.32]) {
                translate([hx, 0.10, 0.10])
                    rotate([0,90,0])
                        color([0.55,0.55,0.58]) cylinder(h=0.45, r=0.10, center=true, $fn=16);
                translate([hx, 0.10, 0.10])
                    rotate([0,90,0])
                        color([0.35,0.35,0.38]) cylinder(h=0.52, r=0.04, center=true, $fn=12);
            }
            // gas struts when open
            if (roof_open) {
                color([0.70,0.70,0.75])
                    hull() {
                        translate([0.42, -0.18, 0.12]) sphere(r=0.045,$fn=8);
                        translate([0.42, -0.24 - sin(ang)*APAS_HATCH_R*0.55, 0.12 + cos(ang)*APAS_HATCH_R*0.55 - APAS_HATCH_R*0.12]) sphere(r=0.035,$fn=8);
                    }
                color([0.70,0.70,0.75])
                    hull() {
                        translate([-0.42, -0.18, 0.12]) sphere(r=0.045,$fn=8);
                        translate([-0.42, -0.24 - sin(ang)*APAS_HATCH_R*0.55, 0.12 + cos(ang)*APAS_HATCH_R*0.55 - APAS_HATCH_R*0.12]) sphere(r=0.035,$fn=8);
                    }
            }
        }
        // docking target cross on ring when closed (visual cue as on ISS PMA-2)
        if (!roof_open) {
            color([0.15,0.15,0.18])
                translate([cx, cy, cz+0.41]) {
                    cube([APAS_RADIUS*1.6, 0.06, 0.02], center=true);
                    cube([0.06, APAS_RADIUS*1.6, 0.02], center=true);
                }
            color([0.92,0.15,0.15])
                translate([cx, cy, cz+0.42]) {
                    cube([APAS_RADIUS*0.9, 0.04, 0.025], center=true);
                    cube([0.04, APAS_RADIUS*0.9, 0.025], center=true);
                }
        }
    }
    // realistic transparent hull — arched glass with Fresnel-like alpha
    if (SHOW_TRANSPARENT)
        % color([0.92, 0.96, 1.0, 0.18])
            union() {
                rotate([0, 90, 0])
                    cylinder(h = MMS_LENGTH*1.02, r = MMS_RADIUS*1.01, center = true, $fn = 64);
                for (sx = [-1, 1])
                    translate([sx * MMS_LENGTH/2, 0, 0])
                        rotate([0, 90, 0]) cylinder(h = 0.62, r = MMS_RADIUS*0.93, center = true, $fn = 48);
            }
}

module greenhouse_interior_realistic() {
    hull_len = MMS_LENGTH * 0.9;
    tier_pitch = (MMS_RADIUS*1.4) / GH_TIERS;
    for (t = [0 : GH_TIERS-1]) {
        z = -MMS_RADIUS*0.65 + t * tier_pitch;
        // aluminium shelf with soil bed
        color(SHELF_ALU) translate([0, 0, z]) cube([hull_len, MMS_RADIUS*1.5, GH_SHELF_THICK], center = true);
        color(SOIL_BROWN) translate([0, 0, z+GH_SHELF_THICK/2+0.04]) cube([hull_len*0.96, MMS_RADIUS*1.46, 0.08], center = true);
        // sprouts — varied greens as in heritage video
        for (x = [-hull_len*0.4 : hull_len*0.22 : hull_len*0.4])
            for (y = [-MMS_RADIUS*0.5 : MMS_RADIUS*0.5 : MMS_RADIUS*0.5]) {
                // vary green per tier
                g = 0.55 + (t % 3)*0.07;
                translate([x, y, z + GH_SHELF_THICK/2 + GH_SPROUT_R + 0.08])
                    color([0.26, g, 0.28])
                        cube([GH_SPROUT_R*1.8, GH_SPROUT_R*1.8, GH_SPROUT_R*2 + (t%2)*0.04], center = true);
            }
    }
    // central aisle (as in heritage video) — gap in middle shelf visuals already via y spacing
    // 7-DoF rail-mounted arm pulled near APAS hatch at TOP Z+ (from Issue 5 sample) — replaces heritage Z-arm
    if (SHOW_ARM) {
        // Sample 7-DoF arm (rail + carriage + 7 joints) scaled and positioned so end-effector can reach APAS opening at ROOF_HATCH_X, Z=MMS_RADIUS
        apas_arm_near_hatch();
        // visual tether from arm tip toward hatch opening (when open)
        if (SHOW_ROOF_HATCH && ROOF_HATCH_OPEN) {
            color([0.95,0.85,0.15,0.55])
                hull() {
                    // tip approx after arm extension — near hatch interior
                    translate([ROOF_HATCH_X + 0.18, 0.08, MMS_RADIUS - 0.55]) sphere(r=0.04,$fn=8);
                    translate([ROOF_HATCH_X, 0, MMS_RADIUS - 0.05]) sphere(r=0.03,$fn=8);
                }
        }
    }
}

module solar_wing_realistic(side) {
    // ISS-style: side-mounted Y±9.2, flat — 2 panels per side, gap 1.2, attached but clears rail Y=1.2
    y_base = side * (MMS_RADIUS + 1.5); // 6+1.5=7.5, panels at 9.65
    color(SPINE_METAL) translate([0, side*(MMS_RADIUS*0.5 + 1.0), 0])
        cube([0.32, MMS_RADIUS*0.5 + 0.6, 0.32], center = true);
    for (p = [-1, 1]) {
        translate([p * (SOLAR_W/2 + SOLAR_GAP/2), y_base + side*(SOLAR_H/2 + 0.4), 0]) { // center at Y±9.65
            rotate([0, SOLAR_ANGLE, 90]) // flat when 0, dynamic when 8
                union() {
                    color(SOLAR_BLACK) cube([SOLAR_W, SOLAR_H, 0.18], center = true);
                    for (gx = [-SOLAR_W*0.33 : SOLAR_W*0.33 : SOLAR_W*0.33])
                        color(SOLAR_GRID) cube([0.06, SOLAR_H*0.98, 0.19], center = true);
                    for (gy = [-SOLAR_H*0.25 : SOLAR_H*0.5 : SOLAR_H*0.25])
                        color(SOLAR_GRID) cube([SOLAR_W*0.98, 0.06, 0.19], center = true);
                    % color([1,1,1,0.08]) translate([0, SOLAR_H*0.3, 0.1]) cube([SOLAR_W*0.9, 0.4, 0.02], center = true);
                }
        }
    }
}

module extraction_beam(p1, p2) {
    if (SHOW_BEAMS) {
        color(BEAM_CYAN)
            hull() {
                translate(p1) sphere(r = BEAM_R*1.5, $fn = 12);
                translate(p2) sphere(r = BEAM_R*1.2, $fn = 12);
            }
        % color(BEAM_GLOW)
            hull() {
                translate(p1) sphere(r = BEAM_R*2.2, $fn = 12);
                translate(p2) sphere(r = BEAM_R*2.0, $fn = 12);
            }
    }
}

module asteroid(r = ASTEROID_R) {
    color(ASTEROID_GREY)
        union() {
            sphere(r = r, $fn = 32);
            // more crater variety as in video 1
            for (a = [0:45:360]) rotate([a*1.1, a*0.6, a*0.3]) translate([r*0.82, 0, 0]) sphere(r = r*0.14 + (a%90)*0.001, $fn = 12);
            for (a = [30:90:300]) rotate([a, -a*0.8, 0]) translate([r*0.88, 0, 0]) sphere(r = r*0.09, $fn = 10);
        }
}

module amu_assembly(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN, roof_ang = APAS_HATCH_ANGLE) {
    if (SHOW_HULL) {
        mms_hull_realistic(open_left_belly, open_right_belly, roof_open, roof_ang);
        if (SHOW_GH) greenhouse_interior_realistic();
    }
    if (SHOW_SOLAR) { solar_wing_realistic(-1); solar_wing_realistic(1); }
    // CORA-M locomotion path — exterior cylindrical rivet waypoints for Space ROS / Gazebo (F5 preview)
    if (SHOW_CORA_PATH) {
        cora_locomotion_path();
        // ghost preview at step 0 (scrub step 0..4 in preview, or animate)
        // cora_locomotion_preview(0);
    }
    // spine not inside hull — variants draw E-W rail outward from bulkheads where needed
}

module variant_single(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN) {
    amu_assembly(open_left_belly, open_right_belly, roof_open, APAS_HATCH_ANGLE);
    if (SHOW_SPINE) translate([MMS_LENGTH/2, 0, 0]) rotate([0,0,90]) spine_double(SPINE_LENGTH*0.35); // flipped N-S (was E-W) — rail now north-south outward from bulkhead
}

module variant_dual(roof_open = ROOF_HATCH_OPEN) {
    // outer closed, inner open — AMUs rotated 90° (now N-S), rail stays E-W between them
    // roof hatches open Atlantis APAS (circular, 115°) by default so greenhouse visible from top
    gap_extra = 6;
    translate([-SPINE_LENGTH/2 - MMS_LENGTH/2 - gap_extra/2, 0, 0]) rotate([0,0,90]) amu_assembly(open_left_belly = false, open_right_belly = true, roof_open = roof_open, roof_ang = APAS_HATCH_ANGLE);
    translate([ SPINE_LENGTH/2 + MMS_LENGTH/2 + gap_extra/2, 0, 0]) rotate([0,0,90]) amu_assembly(open_left_belly = true, open_right_belly = false, roof_open = roof_open, roof_ang = APAS_HATCH_ANGLE);
    spine_double(SPINE_LENGTH+2+gap_extra); // E-W rail unchanged
}

module variant_quad(roof_open = ROOF_HATCH_OPEN) {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([SPINE_LENGTH*0.65, 0, 0])
                rotate([0, 90, 0])
                    amu_assembly(roof_open = roof_open, roof_ang = APAS_HATCH_ANGLE);
    spine_double(SPINE_LENGTH*1.8);
}

module variant_extraction() {
    asteroid(ASTEROID_R);
    positions = [
        [ 22,  8,  6],
        [ 24, -7,  3],
        [-18, 10,  5],
        [-20, -9, -4],
        [  6, 16, -8]
    ];
    for (i = [0 : len(positions)-1]) {
        translate(positions[i]) {
            amu_assembly();
            extraction_beam([0, 0, 0], -positions[i]*0.55);
        }
    }
    translate([0, 18, 12]) color([0.62, 0.62, 0.65]) cylinder(h = 0.5, r = 3, center = true, $fn = 32);
}

// ------------------------------- Render --------------------------------------
variant_dual(roof_open = true); // default — rail between 2 AMUs (E-W, Y=1.2, r0.42) + Atlantis APAS open 115° (circular hatch at TOP Z+ offset X=2.8) — STS-132 — outer closed, inner facing connected
// variant_dual(roof_open = false); // closed (white ring + 3 petals + red target cross)
// variant_single(roof_open = true);  // single AMU — APAS open (greenhouse + arm visible from top)
// variant_single(roof_open = false); // single closed
// variant_quad(roof_open = true);

if (SHOW_DAUGHTER && $preview && false) {
    translate([0, FRAME_SPAN*3.2, 0])
        scale([1, 1, 1])
            amu_assembly();
}

// Uncomment for extraction scene (video 1):
// !variant_extraction();

// Build tips:
// Preview F5 (fast) | Render F6 (CGAL, high $fn) | Export STL/3MF/DXF — for STEP use FreeCAD import
// Desk model: scale([5.7, 5.7, 5.7]) the assembly → 80×30×30mm
// Realism: OpenSCAD max is PBR colors + $fn=64 + grid/specular; true photorealism needs Blender (generate_amu.py:22) with HDRI + textures — ask to generate that next
// Ingested: https://asi.surge.sh/amu + amu-animation-v1.mp4 + heritage_greenhouse_animation-v1.mp4 (2026-09-16)
// Signed: [OpenCode](https://opencode.ai), powered by opencode/muse-spark-1.2-contributor-free — 2026-09-16

