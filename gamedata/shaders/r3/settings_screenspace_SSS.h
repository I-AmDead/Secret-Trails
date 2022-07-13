// [ SETTINGS ] [ SCREEN SPACE SHADOWS ]

#define G_SSS_MAXDISTANCE 				1.0f	// Max distance to render the FX.

#define G_SSS_QUALITY 					2		// Quality of the effect. Affects lenght of the shadow and consistency. ( 0 = low | 1 = medium | 2 = high | 3 = Ultra )
#define G_SSS_REFINE_PASSES				2		// Extra passes to improve shadow visual quality. ( 0 = none | 1 = low | 2 = high | 3 = ultra )

#define G_SSS_DETAILS					0.025f	// Limit detail. Numbers lower than 0.025f will introduce more details to shadows but also incorrect results.
#define G_SSS_FADE						0.3f	// When the shadows begins to fade [ 0.5f = 50% ~ 1.0f = no fade ]

#define G_SSS_INTENSITY					1.0f	// Shadow intensity. [ 0.5f = 50% ~ 1.0f = 100% ]