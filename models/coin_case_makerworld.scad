// ===========================================================================
// Customisable coin case — a hinged, print-in-place box for a single coin.
//
// One file builds both halves. They share one parameter block, so the pocket
// diameter, the outside dimensions and the wall thickness are worked out once
// and used by both halves — the two sides can never drift apart.
//
// Set the coin diameter and thickness and everything else follows: the cavity
// is sized from the coin, and the body grows automatically whenever the coin
// would leave less than `min_wall` of material around it. Up to 8 lines of
// text and an icon are engraved on the outside of the lid. Hold the case with
// the hinge at the bottom and the rounded corners up — that is the way the
// engraving reads.
//
// Pure OpenSCAD CSG geometry (cube / cylinder / hull / rotate_extrude /
// linear_extrude / difference) — no imported meshes.
//
// Printing: pick render_part = "print". Both halves lie flat with the hinge
// already engaged, so the case comes off the plate assembled. Pockets face
// up and need no supports; the engraved face sits on the build plate.
//
// Axes: X — length, Y — thickness (the pocket faces +Y), Z — height.
// ===========================================================================


/* [Output] */
render_part = "print";  // what to build // [part1, part2, assembly, print]

/* [Coin] */
coin_diameter     = 45.2;  // coin diameter, mm // [5:0.1:150]
coin_thickness     = 3.0;  // coin thickness, mm // [0.3:0.1:25]
coin_clearance = 0.4;  // clearance around the coin, per side, mm // [0:0.05:3]

/* [Overall size] */
case_width = 70.0;  // width of one half, mm // [30:0.5:250]
case_height = 70.0;  // height of one half, mm // [30:0.5:250]
case_thickness = 10.0;  // thickness of one half, mm // [4:0.5:50]

min_wall = 1.5;  // minimum wall around the cavity, mm // [0.8:0.1:6]

/* [Coin pockets] */
coin_gap_axial = 0.4;  // free play for the coin through the thickness, mm // [0:0.05:5]
lid_share_of_cavity      = 0.32;  // share of the cavity that goes into the lid // [0.1:0.01:0.9]
lid_pocket_trim      = 0;  // trim the lid pocket deeper or shallower, mm // [-10:0.1:25]
base_pocket_trim     = 0;  // trim the base pocket deeper or shallower, mm // [-10:0.1:25]

/* [Finger notches] */
finger_notch_enable = true;  // add the finger notches
finger_notch_d      = 15.0;  // notch size, mm // [4:0.5:50]
finger_notch_depth  = 6.5;  // notch depth, mm // [0.5:0.1:30]
finger_notch_fillet = 4.0;  // notch bottom fillet, mm // [0:0.1:15]
finger_notch_shape  = 0;  // 0 = round, 1 = rounded square // [0:1]
finger_notch_corner = 3.0;  // corner radius of a square notch, mm // [0.5:0.1:20]

/* [Engraving] */
text_enable = true;  // engrave the text
text_line1 = "HAPPY BIRTHDAY";  // line 1
text_line2 = "TO NATHAN";  // line 2
text_line3 = "FROM DAD";  // line 3
text_line4 = "";  // line 4
text_line5 = "";  // line 5
text_line6 = "";  // line 6
text_line7 = "";  // line 7
text_line8 = "";  // line 8
text_size  = 6.0;  // cap height, mm // [1:0.1:20]
text_line_pitch = 1.45;  // line spacing, multiple of cap height // [1:0.05:3]
text_depth = 0.6;  // engraving depth, mm // [0.1:0.05:3]
text_shift_h = 0;  // shift the text along the lines, right +, mm // [-120:0.5:120]
text_shift_v = 0;  // shift the text across the lines, up +, mm // [-120:0.5:120]
text_font = "Liberation Sans:style=Bold";  // font
// [Liberation Sans:style=Bold, Liberation Sans, Liberation Serif:style=Bold, Liberation Serif, Liberation Mono:style=Bold, Liberation Mono, DejaVu Sans:style=Bold, DejaVu Sans, DejaVu Serif:style=Bold, DejaVu Serif]
text_autofit = true;  // shrink the text automatically so it fits the lid

/* [Icon] */
icon_type     = 0;  // 0=none 1=heart 2=star 3=bell 4=smiley 5=gift 6=crown 7=clover 8=snowflake 9=flower 10=tree, 99=your own picture // [0:10]
icon_size     = 12;  // icon size, mm // [3:0.5:60]
icon_shift_h = 0;  // shift the icon along the lines, right +, mm // [-120:0.5:120]
icon_shift_v = 0;  // nudge the icon across, from its place above the text, mm // [-120:0.5:120]

/* [Hidden] */
custom_icon_pts   = [[0,0]];  // outline of your own picture, traced on the page
custom_icon_paths = [];  // contours of that outline

/* [Preview] */
show_coin = false;  // draw the coin in preview only, never exported

lid_color  = "";  // lid colour, preview only (STL has no colour)
base_color = "";  // base colour, preview only (STL has no colour)

/* [Hidden] */
knuckle_x = 3.5;
knuckle_r = 3.5;
tab_len   = 8.45;
wall_x    = -1.45;
pin_r     = 1.65;
pin_clear = 0.35;
pin_overhang_set = 1.5;
hinge_side_clear = 0.5;

edge_chamfer   = 0.6;
pocket_chamfer_set = 1.0;
boss_y         = 6.8;

$fn = 72;

cav_d = coin_diameter + 2 * coin_clearance;
cav_r = cav_d / 2;

fn_r    = finger_notch_d / 2;
fn_dist = cav_r;

W_need = max(cav_d, finger_notch_enable ? 2 * fn_r : 0) + 2 * min_wall;
H_need = max(cav_d + 2 * min_wall,
             finger_notch_enable ? 2 * (fn_dist + fn_r + min_wall) : 0);
W = max(case_width, W_need);
H = max(case_height, H_need);

cav_need   = coin_thickness + coin_gap_axial;
lid_depth  = max(0.4, cav_need * lid_share_of_cavity       + lid_pocket_trim);
base_depth = max(0.4, cav_need * (1 - lid_share_of_cavity) + base_pocket_trim);

notch_d_eff = finger_notch_enable ? finger_notch_depth : 0;
T = max(case_thickness,
        lid_depth + min_wall,
        base_depth + min_wall,
        notch_d_eff + min_wall);

cav_depth_total = lid_depth + base_depth;
coin_gap        = cav_depth_total - coin_thickness;

corner_r      = min(7.0, H / 2 - 0.5, W / 2 - 0.5);
corner_cz_bot = corner_r;
corner_cz_top = H - corner_r;

gap_half    = min(17.75, H / 2 - 6);
gap_z_lo    = H / 2 - gap_half;
gap_z_hi    = H / 2 + gap_half;
barrel_half = gap_half - hinge_side_clear;
barrel_z_lo = H / 2 - barrel_half;
barrel_z_hi = H / 2 + barrel_half;

knuckle_y   = T;
pin_clear_r = pin_r + pin_clear;
pin_overhang = (render_part == "print") ? 0 : pin_overhang_set;

p1_x0 = tab_len;
p1_x1 = tab_len + W;
p2_x0 = wall_x;
p2_x1 = wall_x - W;

p1_cx = tab_len + W / 2;
p2_cx = wall_x  - W / 2;
face_cz = H / 2;

pocket_chamfer     = min(pocket_chamfer_set, lid_depth * 0.5, cav_r * 0.5);
big_pocket_chamfer = min(pocket_chamfer_set, base_depth * 0.5, cav_r * 0.5);

fn_fillet = min(finger_notch_fillet, fn_r * 0.95, finger_notch_depth * 0.95);
fn_wall_d = finger_notch_depth - fn_fillet;
fn_z_lo   = H / 2 - fn_dist;
fn_z_hi   = H / 2 + fn_dist;

module outline2d(x_inner, dir) {
    x_corner = x_inner + dir * (W - corner_r);
    hull() {
        translate([x_corner, corner_cz_bot]) circle(r = corner_r, $fn = 64);
        translate([x_corner, corner_cz_top]) circle(r = corner_r, $fn = 64);
        translate([x_inner, 0]) circle(r = 0.01, $fn = 12);
        translate([x_inner, H]) circle(r = 0.01, $fn = 12);
    }
}

module p1_outline() { outline2d(p1_x0, +1); }
module p2_outline() { outline2d(p2_x0, -1); }

module xz_extrude(yoff, thick) {
    translate([0, yoff, H])
        rotate([-90, 0, 0])
            linear_extrude(thick)
                children();
}

module chamfered_plate(chamfer) {
    union() {
        xz_extrude(chamfer, T - 2 * chamfer) children();
        hull() {
            xz_extrude(0, 0.01)       offset(-chamfer) children();
            xz_extrude(chamfer, 0.01) children();
        }
        hull() {
            xz_extrude(T - chamfer, 0.01) children();
            xz_extrude(T, 0.01)           offset(-chamfer) children();
        }
    }
}

module knuckle_barrel_profile(x_wall, dir) {
    hull() {
        translate([knuckle_x, knuckle_y]) circle(r = knuckle_r, $fn = 48);
        translate([x_wall + dir * edge_chamfer, 0]) circle(r = 0.01, $fn = 8);
        translate([x_wall, edge_chamfer])           circle(r = 0.01, $fn = 8);
        translate([x_wall, T - edge_chamfer])       circle(r = 0.01, $fn = 8);
        translate([x_wall + dir * edge_chamfer, T]) circle(r = 0.01, $fn = 8);
    }
}

module coin_pocket(cx, depth, chamfer) {
    ov = 2;
    profile = [
        [0, 0],
        [cav_r, 0],
        [cav_r, depth - chamfer],
        [cav_r + chamfer, depth],
        [cav_r + chamfer, depth + ov],
        [0, depth + ov]
    ];
    translate([cx, T - depth, face_cz])
        rotate([-90, 0, 0])
            rotate_extrude($fn = 160) polygon(profile);
}

module p1_knuckle_barrels() {
    linear_extrude(gap_z_lo) knuckle_barrel_profile(p1_x0, +1);
    translate([0, 0, gap_z_hi])
        linear_extrude(H - gap_z_hi) knuckle_barrel_profile(p1_x0, +1);
}

module hinge_pin() {
    translate([knuckle_x, knuckle_y, -pin_overhang])
        cylinder(r = pin_r, h = H + 2 * pin_overhang, $fn = 32);
}

module boss() {
    bh = min(8.3, H * 0.5);
    bz = H / 2 - bh / 2;
    profile = [
        [p1_x1 - 2.4, T],
        [p1_x1,       T],
        [p1_x1,       T + boss_y],
        [p1_x1 - 2.4, T + boss_y],
        [p1_x1 - 3.3, T + boss_y * 0.811],
        [p1_x1 - 2.4, T + boss_y * 0.622]
    ];
    translate([0, 0, bz])
        linear_extrude(bh)
            polygon(profile);
}

module icon_shape(kind, s) {
    if (kind == 1)
        scale(s) polygon(points = [[0,0.2357],[0.0087,0.2767],[0.0336,0.33],[0.0625,0.3688],[0.1015,0.4044],[0.1498,0.4323],[0.1768,0.4421],[0.2347,0.4518],[0.2648,0.4512],[0.3248,0.4388],[0.3537,0.4271],[0.4068,0.3936],[0.4301,0.3723],[0.4679,0.3225],[0.4818,0.2947],[0.4979,0.2353],[0.5,0.2044],[0.4979,0.1732],[0.4818,0.1108],[0.4679,0.0801],[0.4301,0.0201],[0.3537,-0.0652],[0.1498,-0.245],[0.0808,-0.3137],[0.0468,-0.3549],[0.023,-0.3908],[0.0087,-0.4197],[0,-0.4518],[-0.0087,-0.4197],[-0.023,-0.3908],[-0.0468,-0.3549],[-0.0808,-0.3137],[-0.1498,-0.245],[-0.3537,-0.0652],[-0.4301,0.0201],[-0.4679,0.0801],[-0.4818,0.1108],[-0.4979,0.1732],[-0.5,0.2044],[-0.4979,0.2353],[-0.4818,0.2947],[-0.4679,0.3225],[-0.4301,0.3723],[-0.4068,0.3936],[-0.3537,0.4271],[-0.3248,0.4388],[-0.2648,0.4512],[-0.2347,0.4518],[-0.1768,0.4421],[-0.1498,0.4323],[-0.1015,0.4044],[-0.0625,0.3688],[-0.0336,0.33],[-0.0087,0.2767]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]]);
    else if (kind == 2)
        scale(s) polygon(points = [[0,0.4755],[-0.118,0.1123],[-0.5,0.1123],[-0.191,-0.1123],[-0.309,-0.4755],[-0,-0.251],[0.309,-0.4755],[0.191,-0.1123],[0.5,0.1123],[0.118,0.1123]], paths = [[0,1,2,3,4,5,6,7,8,9]]);
    else if (kind == 3)
        scale(s) polygon(points = [[0.0965,-0.4162],[0.0843,-0.4521],[0.0593,-0.4807],[0.0252,-0.4975],[-0.0127,-0.5],[-0.0487,-0.4878],[-0.0689,-0.4723],[-0.09,-0.4407],[-0.0965,-0.4162],[-0.0941,-0.3783],[-0.0843,-0.3548],[-0.0593,-0.3262],[-0.0291,-0.3107],[-0.4822,-0.3107],[-0.4822,-0.1994],[-0.4149,-0.1994],[-0.3326,0.1066],[-0.3225,0.1745],[-0.2891,0.255],[-0.2361,0.3241],[-0.2032,0.3529],[-0.1669,0.3772],[-0.0879,0.41],[-0.0851,0.4355],[-0.0699,0.4663],[-0.0441,0.489],[-0.0115,0.5],[0.0228,0.4978],[0.0536,0.4825],[0.0814,0.4464],[0.0879,0.41],[0.1669,0.3772],[0.2032,0.3529],[0.2649,0.2913],[0.3084,0.2158],[0.3225,0.1745],[0.3326,0.1066],[0.4149,-0.1994],[0.4822,-0.1994],[0.4822,-0.3107],[0.0291,-0.3107],[0.0593,-0.3262],[0.0843,-0.3548],[0.0941,-0.3783]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43]]);
    else if (kind == 4)
        scale(s) polygon(points = [[0.2598,-0.12],[0.238,-0.1526],[0.1826,-0.208],[0.1148,-0.2472],[0.0776,-0.2598],[0,-0.27],[-0.0776,-0.2598],[-0.1148,-0.2472],[-0.1826,-0.208],[-0.238,-0.1526],[-0.2772,-0.0848],[-0.2898,-0.0476],[-0.2993,0.02],[-0.2243,0.02],[-0.2079,-0.0561],[-0.1785,-0.107],[-0.1591,-0.1291],[-0.137,-0.1485],[-0.0861,-0.1779],[-0.0294,-0.1931],[0,-0.195],[0.0294,-0.1931],[0.0861,-0.1779],[0.1125,-0.1649],[0.1591,-0.1291],[0.1785,-0.107],[0.2079,-0.0561],[0.2243,0.02],[0.2993,0.02],[0.2898,-0.0476],[0.4619,-0.1913],[0.433,-0.25],[0.3967,-0.3044],[0.3536,-0.3536],[0.3044,-0.3967],[0.25,-0.433],[0.1913,-0.4619],[0.1294,-0.483],[0.0653,-0.4957],[0,-0.5],[-0.0653,-0.4957],[-0.1294,-0.483],[-0.1913,-0.4619],[-0.25,-0.433],[-0.3044,-0.3967],[-0.3536,-0.3536],[-0.3967,-0.3044],[-0.433,-0.25],[-0.4619,-0.1913],[-0.483,-0.1294],[-0.4957,-0.0653],[-0.5,0],[-0.4957,0.0653],[-0.483,0.1294],[-0.4619,0.1913],[-0.433,0.25],[-0.3967,0.3044],[-0.3536,0.3536],[-0.3044,0.3967],[-0.25,0.433],[-0.1913,0.4619],[-0.1294,0.483],[-0.0653,0.4957],[0,0.5],[0.0653,0.4957],[0.1294,0.483],[0.1913,0.4619],[0.25,0.433],[0.3044,0.3967],[0.3536,0.3536],[0.3967,0.3044],[0.433,0.25],[0.4619,0.1913],[0.483,0.1294],[0.4957,0.0653],[0.5,0],[0.4957,-0.0653],[0.483,-0.1294],[0.3926,0.1626],[0.3681,0.2125],[0.3372,0.2587],[0.3005,0.3005],[0.2587,0.3372],[0.2125,0.3681],[0.1626,0.3926],[0.11,0.4105],[0.0555,0.4214],[0,0.425],[-0.0555,0.4214],[-0.11,0.4105],[-0.1626,0.3926],[-0.2125,0.3681],[-0.2587,0.3372],[-0.3005,0.3005],[-0.3372,0.2587],[-0.3681,0.2125],[-0.3926,0.1626],[-0.4105,0.11],[-0.4214,0.0555],[-0.425,0],[-0.4214,-0.0555],[-0.4105,-0.11],[-0.3926,-0.1626],[-0.3681,-0.2125],[-0.3372,-0.2587],[-0.3005,-0.3005],[-0.2587,-0.3372],[-0.2125,-0.3681],[-0.1626,-0.3926],[-0.11,-0.4105],[-0.0555,-0.4214],[0,-0.425],[0.0555,-0.4214],[0.11,-0.4105],[0.1626,-0.3926],[0.2125,-0.3681],[0.2587,-0.3372],[0.3005,-0.3005],[0.3372,-0.2587],[0.3681,-0.2125],[0.3926,-0.1626],[0.4105,-0.11],[0.4214,-0.0555],[0.425,0],[0.4214,0.0555],[0.4105,0.11],[-0.1153,0.1232],[-0.1305,0.1005],[-0.1532,0.0853],[-0.18,0.08],[-0.2068,0.0853],[-0.2295,0.1005],[-0.2447,0.1232],[-0.25,0.15],[-0.2447,0.1768],[-0.2295,0.1995],[-0.2068,0.2147],[-0.18,0.22],[-0.1532,0.2147],[-0.1305,0.1995],[-0.1153,0.1768],[-0.11,0.15],[0.2447,0.1232],[0.2295,0.1005],[0.2068,0.0853],[0.18,0.08],[0.1532,0.0853],[0.1305,0.1005],[0.1153,0.1232],[0.11,0.15],[0.1153,0.1768],[0.1305,0.1995],[0.1532,0.2147],[0.18,0.22],[0.2068,0.2147],[0.2295,0.1995],[0.2447,0.1768],[0.25,0.15]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],[30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77],[78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125],[126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141],[142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157]]);
    else if (kind == 5)
        scale(s) polygon(points = [[0.4091,-0.5],[-0.4091,-0.5],[-0.4091,0.0909],[-0.4636,0.0909],[-0.4636,0.2455],[-0.2811,0.2455],[-0.2975,0.2682],[-0.3129,0.3055],[-0.3169,0.3656],[-0.2975,0.4227],[-0.2577,0.4681],[-0.2036,0.4947],[-0.1636,0.5],[-0.1045,0.4882],[-0.0696,0.4681],[-0.0298,0.4227],[-0.0104,0.3656],[-0.0144,0.3055],[-0.0298,0.2682],[-0.0462,0.2455],[0.0462,0.2455],[0.0209,0.2863],[0.0104,0.3253],[0.0144,0.3855],[0.0298,0.4227],[0.0544,0.4547],[0.1045,0.4882],[0.1636,0.5],[0.2036,0.4947],[0.2409,0.4793],[0.2729,0.4547],[0.2975,0.4227],[0.3129,0.3855],[0.3182,0.3455],[0.3129,0.3055],[0.2975,0.2682],[0.2811,0.2455],[0.4636,0.2455],[0.4636,0.0909],[0.4091,0.0909],[-0.1046,0.3795],[-0.1221,0.3995],[-0.146,0.4113],[-0.1725,0.4131],[-0.1977,0.4045],[-0.2177,0.387],[-0.2295,0.3631],[-0.2312,0.3366],[-0.2227,0.3114],[-0.2051,0.2914],[-0.1813,0.2796],[-0.1547,0.2779],[-0.1295,0.2864],[-0.1095,0.3039],[-0.0978,0.3278],[-0.096,0.3544],[0.2227,0.3795],[0.2051,0.3995],[0.1813,0.4113],[0.1547,0.4131],[0.1295,0.4045],[0.1095,0.387],[0.0978,0.3631],[0.096,0.3366],[0.1046,0.3114],[0.1221,0.2914],[0.146,0.2796],[0.1725,0.2779],[0.1977,0.2864],[0.2177,0.3039],[0.2295,0.3278],[0.2312,0.3544]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39],[40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55],[56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71]]);
    else if (kind == 6)
        scale(s) polygon(points = [[-0.0125,0.2697],[-0.0364,0.2782],[-0.0577,0.2969],[-0.0702,0.3224],[-0.0721,0.3507],[-0.063,0.3776],[-0.0443,0.3989],[-0.0188,0.4115],[0.0095,0.4133],[0.0364,0.4042],[0.0577,0.3855],[0.0702,0.36],[0.0727,0.3412],[0.0702,0.3224],[0.0577,0.2969],[0.0364,0.2782],[0.0125,0.2697],[0.2091,-0.0679],[0.4141,0.2208],[0.3836,0.2385],[0.366,0.269],[0.3642,0.2956],[0.3777,0.3282],[0.3977,0.3457],[0.4318,0.3549],[0.4579,0.3497],[0.4859,0.3282],[0.4994,0.2956],[0.4948,0.2606],[0.4733,0.2326],[0.4355,0.2187],[0.5,-0.2542],[0.5,-0.4133],[-0.5,-0.4133],[-0.5,-0.2542],[-0.4355,0.2187],[-0.4733,0.2326],[-0.4948,0.2606],[-0.4994,0.2956],[-0.4859,0.3282],[-0.4659,0.3457],[-0.4318,0.3549],[-0.4057,0.3497],[-0.3777,0.3282],[-0.366,0.3043],[-0.366,0.269],[-0.3836,0.2385],[-0.4141,0.2208],[-0.2091,-0.0679]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48]]);
    else if (kind == 7)
        scale(s) polygon(points = [[-0.0197,-0.5],[-0.0245,-0.3654],[-0.0535,-0.3599],[-0.1034,-0.3393],[-0.126,-0.3242],[-0.1641,-0.286],[-0.1911,-0.2393],[-0.1998,-0.2136],[-0.2055,-0.139],[-0.2536,-0.1386],[-0.3058,-0.1246],[-0.3526,-0.0976],[-0.3729,-0.0798],[-0.3907,-0.0594],[-0.4177,-0.0127],[-0.4317,0.0395],[-0.4335,0.0665],[-0.4264,0.1201],[-0.4177,0.1457],[-0.3907,0.1925],[-0.3729,0.2128],[-0.3526,0.2306],[-0.3058,0.2576],[-0.2536,0.2716],[-0.2055,0.272],[-0.2051,0.3201],[-0.1911,0.3723],[-0.1792,0.3966],[-0.1463,0.4394],[-0.1034,0.4723],[-0.0792,0.4843],[-0.0535,0.493],[0,0.5],[0.0535,0.493],[0.0792,0.4843],[0.126,0.4572],[0.1463,0.4394],[0.1641,0.4191],[0.1911,0.3723],[0.2051,0.3201],[0.2055,0.272],[0.2536,0.2716],[0.3058,0.2576],[0.33,0.2457],[0.3729,0.2128],[0.4058,0.17],[0.4177,0.1457],[0.4264,0.1201],[0.4335,0.0665],[0.4264,0.013],[0.4177,-0.0127],[0.3907,-0.0594],[0.3526,-0.0976],[0.3058,-0.1246],[0.2536,-0.1386],[0.2055,-0.139],[0.1998,-0.2136],[0.1792,-0.2635],[0.1641,-0.286],[0.126,-0.3242],[0.0636,-0.3565],[0.0788,-0.5]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61]]);
    else if (kind == 8)
        scale(s) polygon(points = [[-0.0691,-0.4058],[-0.1003,-0.3848],[-0.1066,-0.389],[-0.1498,-0.325],[-0.0691,-0.2705],[-0.1498,-0.2161],[-0.1066,-0.1521],[-0.0386,-0.1979],[-0.0386,-0.1091],[-0.0751,-0.088],[-0.3991,-0.275],[-0.4377,-0.2081],[-0.4337,-0.2058],[-0.4683,-0.1889],[-0.4344,-0.1195],[-0.386,-0.1431],[-0.3834,-0.1056],[-0.3902,-0.1022],[-0.3563,-0.0328],[-0.2689,-0.0754],[-0.2621,0.0216],[-0.185,0.0163],[-0.1907,-0.0655],[-0.1138,-0.0211],[-0.1138,0.0211],[-0.4377,0.2081],[-0.3991,0.275],[-0.3951,0.2727],[-0.3978,0.3111],[-0.3206,0.3165],[-0.3169,0.2628],[-0.2831,0.2792],[-0.2836,0.2868],[-0.2065,0.2922],[-0.1997,0.1951],[-0.1123,0.2378],[-0.0784,0.1683],[-0.152,0.1324],[-0.0751,0.088],[-0.0386,0.1091],[-0.0386,0.4831],[0.0386,0.4831],[0.0386,0.4785],[0.0705,0.5],[0.1137,0.4359],[0.0691,0.4058],[0.1003,0.3848],[0.1066,0.389],[0.1498,0.325],[0.0691,0.2705],[0.1498,0.2161],[0.1066,0.1521],[0.0386,0.1979],[0.0386,0.1091],[0.0751,0.088],[0.3991,0.275],[0.4377,0.2081],[0.4337,0.2058],[0.4683,0.1889],[0.4344,0.1195],[0.386,0.1431],[0.3834,0.1056],[0.3902,0.1022],[0.3563,0.0328],[0.2689,0.0754],[0.2621,-0.0216],[0.185,-0.0163],[0.1907,0.0655],[0.1138,0.0211],[0.1138,-0.0211],[0.4377,-0.2081],[0.3991,-0.275],[0.3951,-0.2727],[0.3978,-0.3111],[0.3206,-0.3165],[0.3169,-0.2628],[0.2831,-0.2792],[0.2836,-0.2868],[0.2065,-0.2922],[0.1997,-0.1951],[0.1123,-0.2378],[0.0784,-0.1683],[0.152,-0.1324],[0.0751,-0.088],[0.0386,-0.1091],[0.0386,-0.4831],[-0.0386,-0.4831],[-0.0386,-0.4785],[-0.0705,-0.5],[-0.1137,-0.4359]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89]]);
    else if (kind == 9)
        scale(s) polygon(points = [[0.3977,0.0009],[0.4456,-0.0687],[0.4612,-0.1471],[0.4456,-0.2255],[0.4012,-0.292],[0.3588,-0.3246],[0.3094,-0.345],[0.2563,-0.352],[0.1988,-0.3435],[0.1893,-0.3735],[0.1626,-0.4198],[0.1247,-0.4577],[0.0784,-0.4844],[0,-0.5],[-0.053,-0.493],[-0.1025,-0.4725],[-0.1449,-0.44],[-0.1775,-0.3975],[-0.1988,-0.3435],[-0.2563,-0.352],[-0.3347,-0.3364],[-0.3811,-0.3097],[-0.4338,-0.2496],[-0.4595,-0.1739],[-0.4595,-0.1204],[-0.4338,-0.0447],[-0.3977,0.0009],[-0.4338,0.0464],[-0.4542,0.0958],[-0.4612,0.1489],[-0.4542,0.2019],[-0.4189,0.2736],[-0.3588,0.3263],[-0.2831,0.352],[-0.2296,0.352],[-0.1988,0.3453],[-0.1893,0.3753],[-0.1626,0.4216],[-0.1025,0.4743],[-0.0267,0.5],[0.053,0.4948],[0.1025,0.4743],[0.1449,0.4417],[0.1775,0.3993],[0.1988,0.3453],[0.2563,0.3538],[0.3094,0.3468],[0.3588,0.3263],[0.4189,0.2736],[0.4542,0.2019],[0.4612,0.1489],[0.4456,0.0704],[0.4189,0.0241]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52]]);
    else if (kind == 10)
        scale(s) polygon(points = [[-0.0812,-0.5],[-0.0812,-0.3016],[-0.4509,-0.3016],[-0.1611,-0.0987],[-0.3698,-0.0987],[-0.1365,0.0862],[-0.2796,0.0862],[-0.0005,0.3563],[-0.061,0.3124],[-0.0377,0.384],[-0.0986,0.4283],[-0.0233,0.4283],[0,0.5],[0.0233,0.4283],[0.0986,0.4283],[0.0377,0.384],[0.061,0.3124],[0.0005,0.3563],[0.2796,0.0862],[0.1365,0.0862],[0.3698,-0.0987],[0.1611,-0.0987],[0.4509,-0.3016],[0.0812,-0.3016],[0.0812,-0.5]], paths = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]]);
    else if (kind == 99)
        scale(s) polygon(points = custom_icon_pts, paths = custom_icon_paths);
}

function _cw(c) =
    (c == " " || c == "." || c == "," || c == ":" || c == ";" || c == "'"
     || c == "!" || c == "|" || c == "i" || c == "j" || c == "l") ? 0.39 :
    (c == "I" || c == "t" || c == "f" || c == "r" || c == "(" || c == ")") ? 0.46 :
    (c == "m" || c == "M" || c == "W" || c == "w" || c == "@") ? 1.20 :
    (c >= "A" && c <= "Z") ? 0.97 :
    (c >= "0" && c <= "9") ? 0.77 :
    0.78;
function _strw(s, i = 0) = i >= len(s) ? 0 : _cw(s[i]) + _strw(s, i + 1);

function _used_lines() = [for (s = [text_line1, text_line2, text_line3,
                                    text_line4, text_line5, text_line6,
                                    text_line7, text_line8]) if (len(s) > 0) s];

module text_engrave() {
    lines = _used_lines();
    n = len(lines);
    avail_line  = H - 2 * (min_wall + 1.5);
    avail_stack = W - 2 * (min_wall + 1.5);
    wmax = n > 0 ? max([for (s = lines) _strw(s)]) : 1;
    icon_res  = icon_type > 0 ? icon_size * 1.25 : 0;
    avail_st2 = avail_stack - icon_res;
    fit_w = wmax > 0 ? avail_line / wmax : text_size;
    fit_h = n > 0 ? avail_st2 / (n * text_line_pitch) : text_size;
    fit   = text_autofit ? min(text_size, fit_w, fit_h) : text_size;
    pitch = fit * text_line_pitch;
    marg = min_wall + 1.5;
    half_line  = wmax * fit / 2;
    half_stack = n * pitch / 2;
    lz_lo = marg + half_line;
    lz_hi = H - marg - half_line;
    sx_lo = p1_x0 + marg + half_stack;
    sx_hi = p1_x1 - marg - half_stack;
    line_z  = min(max(face_cz - text_shift_h, lz_lo), max(lz_lo, lz_hi));
    stack_x = min(max(p1_cx + text_shift_v - icon_res / 2, sx_lo), max(sx_lo, sx_hi));
    ov = 0.3;

    intersection() {
        xz_extrude(-ov, text_depth + ov) {
            union() {
                if (n > 0)
                    for (i = [0:n - 1])
                        translate([stack_x + ((n - 1) / 2 - i) * pitch, H - line_z])
                            mirror([0, 1, 0])
                                rotate(-90)
                                    text(lines[i], size = fit, font = text_font,
                                         halign = "center", valign = "center");
                if (icon_type > 0)
                    let(ihalf  = icon_size / 2,
                        ix_lo  = p1_x0 + marg + ihalf,
                        ix_hi  = p1_x1 - marg - ihalf,
                        iz_lo  = marg + ihalf,
                        iz_hi  = H - marg - ihalf,
                        ix = min(max(stack_x + half_stack + icon_size * 0.6 + icon_shift_v,
                                     ix_lo), max(ix_lo, ix_hi)),
                        iz = min(max(line_z - icon_shift_h, iz_lo), max(iz_lo, iz_hi)))
                    translate([ix, H - iz])
                        mirror([0, 1, 0])
                            rotate(-90)
                                icon_shape(icon_type, icon_size);
            }
        }
        xz_extrude(-ov, T + 2 * ov) offset(-min_wall) p1_outline();
    }
}

module part1() {
    union() {
        difference() {
            union() {
                chamfered_plate(edge_chamfer) p1_outline();
                boss();
                p1_knuckle_barrels();
            }
            coin_pocket(p1_cx, lid_depth, pocket_chamfer);
            if (text_enable) text_engrave();
        }
        hinge_pin();
    }
}

module p2_knuckle_barrel() {
    translate([0, 0, barrel_z_lo])
        linear_extrude(barrel_z_hi - barrel_z_lo)
            knuckle_barrel_profile(p2_x0, -1);
}

module pin_clearance_hole() {
    translate([knuckle_x, knuckle_y, barrel_z_lo - 1])
        cylinder(r = pin_clear_r, h = (barrel_z_hi - barrel_z_lo) + 2, $fn = 32);
}

module fn_section(d) {
    if (finger_notch_shape == 0) {
        circle(r = max(fn_r + d, 0.01), $fn = 72);
    } else {
        c = min(finger_notch_corner, fn_r * 0.95);
        side = max(2 * (fn_r - c), 0.02);
        offset(r = max(c + d, 0.01), $fn = 40) square([side, side], center = true);
    }
}

module finger_notch(z) {
    ov = 2;
    total_d = fn_wall_d + fn_fillet;
    steps = 9;
    translate([p2_cx, T - total_d, z]) rotate([-90, 0, 0]) {
        if (fn_fillet > 0.01) {
            for (i = [0 : steps - 1]) {
                a0 = 90 - i * 90 / steps;
                a1 = 90 - (i + 1) * 90 / steps;
                hull() {
                    translate([0, 0, fn_fillet * (1 - sin(a0))])
                        linear_extrude(0.01) fn_section(-fn_fillet * (1 - cos(a0)));
                    translate([0, 0, fn_fillet * (1 - sin(a1))])
                        linear_extrude(0.01) fn_section(-fn_fillet * (1 - cos(a1)));
                }
            }
        }
        translate([0, 0, fn_fillet])
            linear_extrude(total_d - fn_fillet + ov) fn_section(0);
    }
}

module coin_dummy() {
    translate([p2_cx, T - base_depth, face_cz])
        rotate([-90, 0, 0])
            cylinder(r = coin_diameter / 2, h = coin_thickness, $fn = 96);
}

module part2() {
    difference() {
        union() {
            chamfered_plate(edge_chamfer) p2_outline();
            p2_knuckle_barrel();
        }
        pin_clearance_hole();
        coin_pocket(p2_cx, base_depth, big_pocket_chamfer);
        if (finger_notch_enable) {
            finger_notch(fn_z_lo);
            finger_notch(fn_z_hi);
        }
    }
}

module lay_flat() {
    translate([-knuckle_x, H / 2, 0.02])
        rotate([90, 0, 0])
            children();
}

module tint(c) { if (c == "") children(); else color(c) children(); }

if (render_part == "part1") {
    tint(lid_color) part1();
} else if (render_part == "part2") {
    tint(base_color) part2();
    if (show_coin) %coin_dummy();
} else if (render_part == "assembly") {
    tint(lid_color) part1();
    tint(base_color) part2();
    if (show_coin) %coin_dummy();
} else {
    lay_flat() {
        tint(lid_color) part1();
        tint(base_color) part2();
        if (show_coin) %coin_dummy();
    }
}
