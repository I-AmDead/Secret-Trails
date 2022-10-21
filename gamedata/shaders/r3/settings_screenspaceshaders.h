// [ SETTINGS ] [ SCREEN SPACE REFLECTIONS ]

#define G_SSR_QUALITY					0		// Quality of the SSR. ( 0 = Very low | 1 = Low | 2 = Medium | 3 = High | 4 = Very High | 5 = Ultra )

#define G_SSR_SCREENFADE				0.15f	// Screen border fade. ( 0.0f = No border fade )

#define G_SSR_INTENSITY					1.0f	// Global reflection intensity ( 1.0f = 100% ~ 0.0f = 0% )
#define G_SSR_MAX_INTENSITY				1.0f	// Global reflection MAX intensity.
#define G_SSR_SKY_INTENSITY				0.3f	// Sky reflection intensity

#define G_SSR_WEAPON_MAX_LENGTH			1.3f	// Maximum distance to apply G_SSR_WEAPON_INTENSITY.

#define G_PUDDLES_SCALE					0.1f
#define G_PUDDLES_SLOPE_THRESHOLD		0.8f

#define G_PUDDLES_TINT					float3(0.55f, 0.55f, 0.55f) // Puddles tint RGB.

#define G_PUDDLES_RIPPLES							// Comment to disable ripples
#define G_PUDDLES_RIPPLES_SCALE			2.5f	// Ripples scale
#define G_PUDDLES_RIPPLES_INTENSITY		5.0f	// Puddles ripples intensity
#define G_PUDDLES_RIPPLES_RAINING_INT	0.0f	// Extra ripple intensity when raining ( Affected by rain intensity )
//#define G_PUDDLES_RIPPLES_SPEED			1.0f	// Puddles ripples movement speed


// [ SETTINGS ] [ SCREEN SPACE REFLECTIONS ON WATER]

#define G_SSR_WATER_QUALITY 0
#define G_SSR_WATER_SCREENFADE			0.3f	// Screen border fade. ( 0.0f = No border fade )

// [ SETTINGS ] [ SCREEN SPACE SHADOWS ]

#define USE_SSS

#define G_SSS_STEPS						16		// More steps = better quality / poor performance. ( 24 = Low | 32 = Medium | 48 = High | 64 = Ultra )

#define G_SSS_INTENSITY					1.0f	// Shadow general intensity. [ 0.5f = 50% ~ 1.0f = 100% ]
#define G_SSS_DETAILS					0.02f	// Limit detail. Lower values will introduce more details to shadows but also incorrect results.
#define G_SSS_FORCE_FADE				0.5f	// Force shadow to start to fade at [ 0.5f = 50% ~ 1.0f = no fade ]

#define G_SSDO_WEAPON_LENGTH			1.5f	// Maximum distance to apply weapon factors.
#define G_SSDO_WEAPON_HARDNESS			1.0f	// Weapon shadow hardness. 0.0f to disable weapon shadows.
#define G_SSDO_WEAPON_SHADOW_LENGTH		0.1f	// Weapon maximum shadow length.

