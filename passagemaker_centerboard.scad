// Measured dimensions of the centerboard

// Helper functions, including sizing to support scaling later.
function MM(x) = x;
function INCH(x) = MM(25.4)*x;

//              < fore          aft >
// 
// 
//                     <-chord_max->
//                     _____________  daggerboard handle top
//    handle_height -> |           | 
//                     +- - - - - -+  daggerboard trunk top
//                   ^ |           | 
//                   | |           | 
//      trunk_height | |           |
//                   v |           | 
//                     +- - - - - -+  waterline
//   straight_height ->|           | 
//                   ^ \           |  foil shape required below waterline
//                   |  \          |
//                   |   \         |
//      taper_height |    \        |
//                   |     \       |
//                   v      \______|
//                           <----->
//                          chord_min


passagemaker_centerboard_handle_height = INCH(0); // unimplemented
passagemaker_centerboard_trunk_height = INCH(12);
passagemaker_centerboard_straight_height = INCH(1);
passagemaker_centerboard_taper_height = INCH(27);

passagemaker_centerboard_total_height = passagemaker_centerboard_handle_height + passagemaker_centerboard_trunk_height + passagemaker_centerboard_straight_height + passagemaker_centerboard_taper_height;

passagemaker_centerboard_chord_max = INCH(12.25);
passagemaker_centerboard_chord_min = INCH(7.5);
passagemaker_centerboard_thickness = MM(13);

// estimated. Useful if you want a foil that's thicker than the standard plywood.
passagemaker_centerboard_trunk_thickness = MM(15);

// estimated. Useful if you want a foil that's got a longer chord than the standard plywood.
passagemaker_centerboard_trunk_length = INCH(12.5);

passagemaker_planform_points = [
  [0, 0],
  [passagemaker_centerboard_straight_height, 0],
  [passagemaker_centerboard_straight_height + passagemaker_centerboard_taper_height,passagemaker_centerboard_chord_max - passagemaker_centerboard_chord_min],
  [passagemaker_centerboard_straight_height + passagemaker_centerboard_taper_height,passagemaker_centerboard_chord_max],
  [passagemaker_centerboard_straight_height, passagemaker_centerboard_chord_max],
  [0,passagemaker_centerboard_chord_max]
];

passagemaker_planform_profiles = [
  [passagemaker_planform_points[0], passagemaker_planform_points[5]],
  [passagemaker_planform_points[1], passagemaker_planform_points[4]],
  [passagemaker_planform_points[2], passagemaker_planform_points[3]],
];
    
module passagemaker_planform() {
    polygon(passagemaker_planform_points);
}

passagemaker_trunk_points = [
  [0,0],
  [passagemaker_centerboard_handle_height + passagemaker_centerboard_trunk_height, 0],
  [passagemaker_centerboard_handle_height + passagemaker_centerboard_trunk_height, passagemaker_centerboard_chord_max],
  [0,passagemaker_centerboard_chord_max]
];
    
module passagemaker_trunk() {
    polygon(passagemaker_trunk_points);
}

