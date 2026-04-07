// [ SETTINGS ] [ LUT ]

#define G_LUT_SIZE_W 1024.0 // Width of your LUT texture
#define G_LUT_SIZE_H 544.0 // Width of your LUT texture

#define G_CELLS_SIZE 32 // Width/Height of your cell
#define G_CELLS_GROUPS G_LUT_SIZE_H / G_CELLS_SIZE // Quantity of tables in your texture

#define G_ADVANCE_TRANSITION // Note for Modders: You can enable this option to do smooth transitions between tables in realtime. Check the script