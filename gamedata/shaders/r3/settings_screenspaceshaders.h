// [ SETTINGS ] [ SCREEN SPACE REFLECTIONS ]

#define G_SSR_QUALITY					2		// Quality of the SSR. ( 0 = Very low | 1 = Low | 2 = Medium | 3 = High | 4 = Very High | 5 = Ultra )

#define G_SSR_SCREENFADE				0.15f	// Screen border fade. ( 0.0f = No border fade )

#define G_SSR_INTENSITY					1.3f	// Global reflection intensity ( 1.0f = 100% ~ 0.0f = 0% )
#define G_SSR_MAX_INTENSITY				0.5f	// Global reflection MAX intensity.
#define G_SSR_SKY_INTENSITY				0.6f	// Sky reflection intensity ( 1.0f = 100% ~ 0.0f = 0% )
#define G_SSR_FLORA_INTENSITY 			0.5f	// Adjust grass and tree branches intensity
#define G_SSR_TERRAIN_BUMP_INTENSITY	0.6f	// Terrain bump intensity ( Lower values will generate cleaner reflections )

#define G_SSR_WEAPON_INTENSITY  		0.5f	// Weapons & arms reflection intensity. ( 1.0f = 100% ~ 0.0f = 0% )
#define G_SSR_WEAPON_MAX_INTENSITY		0.015f	// Weapons & arms MAX intensity.
#define G_SSR_WEAPON_MAX_LENGTH			1.3f	// Maximum distance to apply G_SSR_WEAPON_INTENSITY.
#define G_SSR_WEAPON_RAIN_FACTOR		0.2f	// Weapons reflections boost when raining ( 0 to disable ) ( Affected by rain intensity )


// [ SETTINGS ] [ PUDDLES ]

// NOTE: Reflection quality is defined by G_SSR_QUALITY ( settings_screenspace_SSR.h )

#define G_PUDDLES_GLOBAL_SIZE				1.0f	// Puddles global size. ( This affect distance and puddles size )
#define G_PUDDLES_SIZE						0.8f	// Puddles individual size. ( This only affect puddles size )
#define G_PUDDLES_BORDER_HARDNESS			0.7f	// Border hardness. ( 1.0f = Extremely defined border )
#define G_PUDDLES_TERRAIN_EXTRA_WETNESS		0.15f	// Terrain extra wetness when raining. ( Over time like puddles )
#define G_PUDDLES_REFLECTIVITY				0.4f	// Reflectivity. ( 1.0f = Mirror like )
#define G_PUDDLES_TINT						float3(0.8f, 0.7f, 0.6f) // Puddles tint RGB.

#define G_PUDDLES_RIPPLES							// Comment to disable ripples
#define G_PUDDLES_RIPPLES_SCALE				1.0f	// Ripples scale
#define G_PUDDLES_RIPPLES_INTENSITY			1.0f	// Puddles ripples intensity
#define G_PUDDLES_RIPPLES_RAINING_INT		0.1f	// Extra ripple intensity when raining ( Affected by rain intensity )
#define G_PUDDLES_RIPPLES_SPEED				1.0f	// Puddles ripples movement speed


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

