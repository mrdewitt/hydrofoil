use <openscad-airfoil/n/naca0006.scad>
use <openscad-airfoil/n/naca0004.scad>
use <parametric-loft/loft.scad>
use <parametric-loft/pcurve.scad>
include <Round-Anything/polyround.scad>
include <passagemaker_centerboard.scad>

// Measured dimensions of the centerboard
taper_height = passagemaker_centerboard_taper_height;
chord_max = passagemaker_centerboard_chord_max;
chord_min = passagemaker_centerboard_chord_min;
original_thickness = passagemaker_centerboard_thickness;

// helper
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

// Mathematical definitions for the pollock section. It is a flat sided section, and so
// it has two parameters along with the thickness to chord-length ratio (`t`):
//  - Xle: the fraction of the chord occupied by the leading curve.
//  - Xtl: the fraction of the chord occupided by the trailing taper.
//
// In order to be flat sided, `Xle + Xtl < 1` must hold.
//
// Interestingly, the section works well with a relatively small Xle and a wide variety of
// Xtl parameters (citation needed). This makes the section very easy to taper, as a single
// nose jig and tail jig need to be made, so long as the implied `Xle` and `Xtl` remain small
// enough.
//
// Flat sided sections are also well suited for creating by hand as they are always stable on
// a flat tabletop or the like.

function pollock_nose(x_1, Xle, t) = t/2*( 8*sqrt(x_1)/(3*sqrt(Xle)) - 2*x_1/Xle + x_1^2/(3*Xle^2) );
function pollock_tail(x_2, Xtl, t) = t/2*(1 - (3*x_2^2)/(2*Xtl^2) + x_2^3/(2*Xtl^3));

module nose(t, Xle, $fn = 30) {
    let (scale = 100,
        nose_points =        [ for (x_1 = [0 :Xle/$fn : Xle]) [x_1*100,    scale*pollock_nose(x_1, Xle, t)]],
        bottom_nose_points = [ for (x_1 = [0 :Xle/$fn : Xle]) [x_1*100, -1*scale*pollock_nose(x_1, Xle, t)]])
    
   polygon(points=concat(reverse(nose_points), bottom_nose_points));

}

module tail(t, Xtl, $fn = 30) {
    let (scale = 100,
       extra_Xtl = Xtl + 0.05,
       tail_points =        [ for (x = [0 :extra_Xtl/$fn : extra_Xtl]) [(x)*100,    scale*pollock_tail(x, extra_Xtl, t)]],
      bottom_tail_points = [ for (x = [0 :extra_Xtl/$fn : extra_Xtl]) [(x)*100, -1*scale*pollock_tail(x, extra_Xtl, t)]]) {
        echo("2*Xtl*t: ", extra_Xtl*t);
        intersection() {
            translate([0, -scale*t/2, 0]) square([scale*Xtl, scale*t], center=false);
            polygon(points=concat(reverse(tail_points), bottom_tail_points));
        }
   }
}

module center(t, Xle, Xtl) {
        polygon(points=[
            [0,-100*t/2],
            [0,100*t/2],
            [100*(1-Xtl)-100*Xle,100*t/2],
            [100*(1-Xtl)-100*Xle,-100*t/2]
        ]);
}

module pollock_taper(height, t, chord_length_max, chord_length_min, Xtl, Xle) { 
    let (nose_length = chord_length_max*Xle,
         tail_length = chord_length_max*Xtl,
         taper_distance = (chord_length_max-chord_length_min),
         center_length = chord_length_max * (1 - Xle - Xtl),
         taper_pct = (center_length - taper_distance) / center_length,
         // Need to lengthen the tail as it is being extruded in a non-vertical dimension.
         nose_height = sqrt(taper_distance^2 + height^2)) {
            linear_extrude(nose_height, v = [taper_distance, 0, height]) {
                scale([chord_length_max / 100, chord_length_max / 100]) nose(t, Xle = Xle);
            }
            #translate([chord_length_max-tail_length,0,0])  linear_extrude(height, scale=[taper_pct,1]) {
                scale([-chord_length_max / 100, chord_length_max / 100]) center(t, Xle = Xle, Xtl = Xtl);
            }
            translate([chord_length_max - tail_length,0,0]) linear_extrude(height) {
                scale([chord_length_max / 100, chord_length_max / 100]) tail(t, Xtl = Xtl);
            }
    }
    
}

module pollock_straight(height, t, chord_length, Xtl) {
    let (Xle = 4*t,
         nose_length = chord_length*Xle,
         tail_length = chord_length*Xtl,
         center_length = chord_length - nose_length - tail_length) {
            linear_extrude(height) {
                scale([chord_length / 100, chord_length / 100]) nose(t, Xle = Xle);
            }
            translate([chord_length-tail_length,0,0])  linear_extrude(height) {
                scale([-chord_length / 100, chord_length / 100]) center(t, Xle = Xle, Xtl = Xtl);
            }
            translate([chord_length - tail_length,0,0]) linear_extrude(height) {
                scale([chord_length / 100, chord_length / 100]) tail(t, Xtl = Xtl);
            }
    }
}

module pollock_section(t, chord_length, Xtl, $fn = 30) {
    let (Xle = 4*t,
         nose_length = chord_length*Xle,
         tail_length = chord_length*Xtl,
         center_length = chord_length - nose_length - tail_length) {
            scale([chord_length / 100, chord_length / 100]) nose(t, Xle = Xle, $fn=$fn);
            translate([chord_length-tail_length,0,0]) {
                scale([-chord_length / 100, chord_length / 100]) center(t, Xle = Xle, Xtl = Xtl);
            }
            translate([chord_length - tail_length,0,0]) {
                scale([chord_length / 100, chord_length / 100]) tail(t, Xtl = Xtl, $fn=$fn);
            }
    }
}

module pollock_dimens(thickness, chord_length, leading_taper_length, tail_taper_length, $fn = 30) {
    let (t = thickness / chord_length, Xtl = tail_taper_length / chord_length) {
        pollock_section(t, chord_length, Xtl, $fn);
    }
}

pollock_taper(taper_height, original_thickness/chord_max, chord_max, chord_min, 0.4, 0.2);

