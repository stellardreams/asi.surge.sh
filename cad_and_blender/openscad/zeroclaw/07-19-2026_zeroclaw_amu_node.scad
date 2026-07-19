// ============================================================
// AMU Structural Node + Strut Connector  (parametric)
// Autonomous Manufacturing Unit - self-replicating lattice vocab
// ============================================================

// ---- Parameters (edit these) ----
node_radius   = 12;     // sphere node radius (mm)
node_hole     = 4.5;    // bolt hole radius through node
arm_length    = 30;     // strut arm length from node center
arm_dia       = 8;      // strut arm diameter
flange_dia    = 14;     // connector flange diameter
flange_thick  = 3;      // flange thickness
bolt_holes    = 6;      // bolt holes around each flange
bolt_dia      = 2.5;    // bolt hole diameter
faces         = 6;      // symmetry: 6 = octahedral-ish lattice node

// ---- Node body ----
module node() {
  difference() {
    sphere(r = node_radius, $fn = 48);
    // central through-bolt hole
    cylinder(h = node_radius*2.2, r = node_hole, center = true, $fn = 24);
  }
}

// ---- One strut arm with flange + bolt circle ----
module strut() {
  // arm
  cylinder(h = arm_length, r = arm_dia/2, center = false, $fn = 24);
  // flange at tip
  translate([0, 0, arm_length - flange_thick])
    cylinder(h = flange_thick, r = flange_dia/2, $fn = 32);
  // bolt circle
  for (i = [0 : bolt_holes-1]) {
    a = i * 360 / bolt_holes;
    translate([ (flange_dia/2 - bolt_dia*1.5) * cos(a),
                (flange_dia/2 - bolt_dia*1.5) * sin(a),
                arm_length - flange_thick/2 ])
      rotate([0,0,a])
        cylinder(h = flange_thick*1.2, r = bolt_dia/2, center = true, $fn = 16);
  }
}

// ---- Assemble: node + arms radiating on a sphere ----
module amu_node() {
  node();
  for (i = [0 : faces-1]) {
    a = i * 360 / faces;
    // tilt arms up/down alternately for 3D lattice spread
    tilt = (i % 2 == 0) ? 35 : -35;
    rotate([0, tilt, a]) strut();
  }
}

amu_node();
