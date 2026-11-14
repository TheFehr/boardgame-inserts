// Homestead Hyperjump insert (Boardgame Insert Toolkit).
// Dimensions come from the measurements table (see vault note
// homestead-hyperjump-measurements). Unsleeved cards.
include <../../lib/boardgame_insert_toolkit_lib.4.13.0.scad>;

/* [Tray] */
// Which tray to render (each prints on its own, bed 256 x 256)
tray = "chance_green"; // [chance_green, chance_yellow, chance_red, sector_green, sector_yellow, sector_red, hex_green, hex_yellow, hex_red, characters, misc_top, misc_tokens, cards_small, ship]

/* [Box (inner, mm)] */
box_width = 285; // [200:1:400]
box_depth = 285; // [200:1:400]
box_height = 72; // [30:1:120]  (caliper depth 72.47 inside, 2026-11-13; 0.47 spare)
// Layers from the top: main board, 3 encounter booklets, then (at the back) the
// 6 player boards on the characters tray; trays fill the rest down to the floor.
main_board = 10.12;  // folded main board, 285 x 285 (caliper 2026-11-14)
rulebook = 3;        // main rule book, full 285 x 285 footprint, between booklets and main board
booklets = 9;        // 3 Encounter Booklets, 210 x 278 (ruler photos 2026-11-13)
player_boards = 22.9; // 6 boards, 240 x 125, back-left (caliper tray+boards 45.92, 2026-11-14)
char_tray = 23;      // characters tray is printed at 23 mm; boards end 4 mm under the booklets

/* [Print] */
wall_thickness = 2; // [1:0.1:4]
tolerance = 0.15; // [0:0.05:0.5]
// Extra room around every compartment
pad = 0.5; // [0:0.1:2]

/* [Cards] */
chance_w = 71;  chance_h = 100;
char_w = 80;    char_h = 120;    // characters + micro-expansion + SOS share a well
sd_w = 70;      sd_h = 70;       // Sector Data and "You have Died"
small_w = 44;   small_h = 67;    // Salvage, Assignment

/* [Hex tiles] */
// Tile is a regular hex: 39 across the flats, 44 across the points (note had them swapped)
hex_w = 44;   // across the points

/* [Tokens, cubes] */
token_d = 22;
cube = 8.5;
cubes_per_color = 10;

/* [Ship (assembled)] */
ship_w = 47.6;  // caliper 47.54 (2026-11-13)
ship_l = 83.2;  // caliper 83.19 (2026-11-13)
ship_h = 49.4;  // caliper 49.34 (2026-11-13)

wall = wall_thickness;
g = wall;
slack = 1.5;   // extra height above the stack
hex_stack = 37;

// Total tray height (incl. lid) per tray; cavity = total - 3*wall.
//  Booklets lie at box_height - 10 - 9 = 53 .. 62, the player boards below them at the back.
//  Back strip (under the boards): 72 - 10 - 9 - 30 = 23. Front columns: chance 27.5 + sector 25.5
//  = 53. The right-hand columns (ship, small cards, misc) are not covered by booklets: 62.
function tray_total(t) =
    t == "chance_green" || t == "chance_yellow" || t == "chance_red" ? 27.5 :        // 20 stack + slack, sector tray on top
    t == "sector_green" || t == "sector_yellow" || t == "sector_red" ? box_height - main_board - rulebook - booklets - 27.5 :   // 22.4 -> stack top at the booklets
    t == "hex_green" || t == "hex_yellow" || t == "hex_red" ? hex_stack + 0.5 + 3*wall :
    t == "characters" ? char_tray :                                                // 23 (printed)
    t == "misc_tokens" ? 28.5 + slack + 3*wall :                                     // 36: two token stacks
    t == "misc_top" ? box_height - main_board - rulebook - (28.5 + slack + 3*wall) :  // 22.9: dice, bars, cubes, on top of misc_tokens
    box_height - main_board - rulebook;                                             // cards_small, ship: up to the rulebook
function tray_cmp(t) = tray_total(t) - 3*wall;
cmp_h = tray_cmp(tray);
box_urz = cmp_h + 2*wall;   // the sliding lid adds one more wall on top

function feat(name, w, d, x, y, cut=false, cut_pct=100) = [ BOX_FEATURE,
    [ NAME, name ],
    [ FTR_COMPARTMENT_SIZE_XYZ, [w + pad, d + pad, cmp_h] ],
    [ POSITION_XY, [x, y] ],
    [ FTR_CUTOUT_SIDES_4B, [cut, false, false, false] ],
    [ FTR_CUTOUT_HEIGHT_PCT, cut_pct ],   // <100 leaves a lip so small parts cannot slide out
];
function hex_feat(name, x, y) = [ BOX_FEATURE,
    [ NAME, name ],
    [ FTR_COMPARTMENT_SIZE_XYZ, [hex_w + 1, hex_w + 1, cmp_h] ],
    [ POSITION_XY, [x, y] ],
    [ FTR_SHAPE, HEX ],
    [ FTR_SHAPE_VERTICAL_B, true ],
    [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
];
function round_feat(name, d, x, y) = [ BOX_FEATURE,
    [ NAME, name ],
    [ FTR_COMPARTMENT_SIZE_XYZ, [d + pad, d + pad, cmp_h] ],
    [ POSITION_XY, [x, y] ],
    [ FTR_SHAPE, ROUND ],
    [ FTR_SHAPE_VERTICAL_B, true ],
    [ FTR_CUTOUT_SIDES_4B, [false, false, true, false] ],   // left: finger slot to grip the stack
];

dice_well = 40;   // d6 12 mm, d8 23.8 x 15.6 (caliper 2026-11-13)
cube_w = 2*cube + pad + 1;
cube_d = cubes_per_color/2*cube + 1;

function tray_features(t) =
    t == "chance_green" || t == "chance_yellow" || t == "chance_red"
        ? [ feat("Chance", chance_w, chance_h, 0, 0, true) ] :
    t == "sector_green" || t == "sector_yellow" || t == "sector_red"
        ? [ feat("Sector Data", sd_w, sd_h, 0, 0, true) ] :
    t == "hex_green" || t == "hex_yellow" || t == "hex_red"
        ? [ hex_feat("Hex", 0, 0) ] :
    t == "characters"   // 240 x 125: cards | micro | 6 cube wells (3 x 2)
        ? [ feat("Characters + SOS + Died", char_w, char_h, 0, 0, true),
            feat("Micro-Expansion", 75, 105, char_w + pad + g, 0, true),
            for (i = [0:5])
                feat(str("Cubes ", i + 1), 2*cube + 1, cube_d,
                     char_w + 75 + 2*pad + 2*g + (i % 3)*(cube_w + g),
                     floor(i / 3)*(cube_d + pad + g)) ] :
    t == "misc_tokens"   // bottom of the back-right column
        ? [ round_feat("Tokens 1", token_d, 0, 0),
            round_feat("Tokens 2", token_d, 0, token_d + pad + g) ] :
    t == "misc_top"      // top of the back-right column: shallow wells, easy to reach into
        ? [ feat("D6 x6 + red cube", dice_well, dice_well, 0, 0, true, 40),
            feat("d8 x2 (23.8 x 15.6)", 25, 49.5, 0, dice_well + pad + g, true, 40),
            // gold cubes in a column beside the d8: 17 mm free at one end to get a finger in
            feat("Gold cubes x3 (10.2)", 12.5, 49.5, 25 + pad + g, dice_well + pad + g),
            // bars stacked flat, with a free strip beside the stack to grip them
            feat("Credit bars x3 (31.8 x 7.7 x 4.6)", 33, 22, 0, dice_well + pad + g + 49.5 + pad + g) ] :
    t == "cards_small"   // standing on the 44 mm edge
        ? [ feat("Salvage",    20, small_h, 0, 0, true),
            feat("Assignment", 20, small_h, 20 + pad + g, 0, true) ] :
    /* ship */ [ feat("Ship", ship_w, ship_l, 0, 0) ];

// Outer footprint [w, d] of every tray, stretched so the trays tile the box
// exactly (nothing can shift or rattle). Compartments sit in the front-left corner.
function tray_fill(t) =
    t == "chance_green" || t == "chance_yellow" || t == "chance_red" ? [76, 108] :
    t == "sector_green" || t == "sector_yellow" || t == "sector_red" ? [76, 108] :
    t == "hex_green" || t == "hex_yellow" || t == "hex_red" ? [76, 52] :
    t == "characters" ? [240, 125] :
    t == "misc_top" || t == "misc_tokens" ? [box_width - 240, 125] :
    t == "cards_small"? [57, 2*wall + small_h + pad] :
    /* ship */          [57, 2*wall + ship_l + pad];
function tray_size(t) = [ tray_fill(t)[0], tray_fill(t)[1], box_urz ];

data = [
    [ G_TOLERANCE, tolerance ],
    [ G_WALL_THICKNESS, wall ],
    [ OBJECT_BOX,
        [ NAME, tray ],
        [ BOX_SIZE_XYZ, tray_size(tray) ],
        each tray_features(tray),
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_PATTERN_RADIUS, 8 ],
            [ LID_PATTERN_THICKNESS, 1.6 ],   // rib width; default 0.5 was flimsy
        ],
    ],
];

Make(data);
