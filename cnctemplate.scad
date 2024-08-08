use <flatsided.scad>
include <passagemaker_centerboard.scad>

// Measured dimensions of the centerboard
trunk_height = passagemaker_centerboard_trunk_height;
taper_height = passagemaker_centerboard_taper_height;
chord_max = passagemaker_centerboard_chord_max;
chord_min = passagemaker_centerboard_chord_min;
original_thickness = passagemaker_centerboard_thickness;

screw_shaft_6 = INCH(0.138);

t=original_thickness / chord_max;
Xtl = 0.4;
Xle = 0.2;

function square_bit_depth(depth, width) = sqrt(depth^2 + width^2);

bit_depth = MM(10);
bit_width = MM(6.35);
bit_max_depth = square_bit_depth(bit_depth, bit_width);

kerf=MM(.2);

module add_kerf(k = kerf) {
    offset(r=k/2) children();
}

module pollock(chord, foil_thickness = original_thickness, router_depth = 0) {
  offset(r=router_depth) pollock_dimens(foil_thickness, chord, Xle * chord_max, Xtl * chord_max, $fn=200);
}

module layout() {
    translate([bit_max_depth,original_thickness/2+bit_max_depth + kerf,0]) {
        for (i=[0:$children-1]) {
            translate([0, i*MM(35), 0]) children(i);
        }
    }
}

module table_layout(chord = chord_max, foil_thickness = original_thickness, stock_thickness = original_thickness) {
    union() {
        intersection() {
            translate([-bit_max_depth,-stock_thickness/2]) square([chord+2*bit_max_depth, stock_thickness + bit_max_depth]);
            difference() {
                union() {
                    offset(r=bit_max_depth) pollock(chord, foil_thickness = foil_thickness);
                    
                    translate([-bit_max_depth,-stock_thickness/2]) {
                        square([chord+2*bit_max_depth, stock_thickness/2]);
                    };
                }
                union() {
                    pollock(chord, foil_thickness = foil_thickness);
                    translate([0,-stock_thickness/2]) square([chord, stock_thickness/2]);
                };
            }
        }

    }
}

module router_layout() {
  difference() {
    square([INCH(3), INCH(1)]);
    translate([(INCH(3) - bit_width)/2, 0]) square([bit_width, bit_depth]);
  };
}

module router_template_minkowski(chord = chord_max) {
    difference() {
        minkowski(10) {
          linear_extrude(1) pollock(chord);
          cylinder(1, r=bit_max_depth);
        }
        translate([0,0,-1]) linear_extrude(4) pollock(chord);
        
        translate([30,0,0]) cylinder(4, r=screw_shaft_6/2);
        translate([(chord + bit_max_depth - 60 - 30)/2+30,0,0]) cylinder(4, r=screw_shaft_6/2);
        translate([chord + bit_max_depth - 60,0,0]) cylinder(4, r=screw_shaft_6/2);

    };
}

module screw_holes(chord, $fn=50) {
     {
        translate([30,0]) circle(r=screw_shaft_6/2);
        translate([(chord + bit_max_depth - 60 - 30)/2+30,0]) circle(r=screw_shaft_6/2);
        translate([chord + bit_max_depth - 60,0]) circle(r=screw_shaft_6/2);
    };
}

module router_template(chord = chord_max) {
    difference() {
        pollock(chord, router_depth=bit_max_depth);
        //remove screw holes
        screw_holes(chord);
    };
}

module stock_layout(chord = chord_max, stock_thickness = original_thickness) {
    add_kerf()
    translate([-bit_max_depth, 0]) difference() {
        square([chord, stock_thickness]);
        translate([0, stock_thickness/2]) screw_holes(chord);
    }
}

module nose_tail_guides(stock_thickness = 2*original_thickness) {
    translate([-bit_max_depth, 0]) {
        difference() {
            square([chord_max * Xle + INCH(1), stock_thickness]);
            translate([INCH(0.5), stock_thickness/2]) pollock(chord_max);
        };
        translate([INCH(1)+INCH(2)-(chord_max * (1-Xle-Xtl)), 0, 0])
        difference() {
            translate([chord_max * (1-Xtl)-INCH(1), 0, 0]) square([chord_max * Xtl + INCH(1.5), stock_thickness]);
            translate([0, stock_thickness/2]) pollock(chord_max);
        };
    }
}


let (template_thickness = MM(25)) {
    add_kerf() layout() {
        table_layout(foil_thickness = original_thickness, stock_thickness = template_thickness);
        table_layout(chord_min, foil_thickness = original_thickness, stock_thickness = template_thickness);
        stock_layout(chord_min);
        stock_layout(chord_max);
        stock_layout(chord=chord_min, stock_thickness = template_thickness);    
        stock_layout(stock_thickness = template_thickness);
        router_layout();
        nose_tail_guides(template_thickness);
    };
}
