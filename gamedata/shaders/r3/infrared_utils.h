#include "common.h"

///////////////////////////////////////////////////////
//      BEEF'S SHADER BASED NIGHT VISION EFFECT      //
///////////////////////////////////////////////////////
// Huge credit TO LVutner from Anomaly Discord, who  //
// literally taught me everything I know, to Sky4Ace //
// who's simple_blur function I've adapted for this  //
// shader, and to Meltac, who provided some advice   //
// and inspiration for developing this shader.       //
///////////////////////////////////////////////////////
// Note: You are free to distribute and adapt this   //
// Shader and any components, just please provide    //
// credit to myself and/or the above individuals. I  //
// have provided credit for individual functions and //
// their original authors where applicable.	- BEEF   //
///////////////////////////////////////////////////////


float rand(float n)
{
    return frac(cos(n)*343.42);
}

///////////////////////////////////////////////////////
// USER SETTINGS HERE
///////////////////////////////////////////////////////

//////// GLOBAL SETTINGS(ALL GENERATIONS)////////
// NVG CRT & NOISE VALUES
//(BE AWARE THAT NOISE AND SCINTILLATION SCALE WITH NVG GAIN)

#define gen_3_nvg_noise_factor float (0.08)				// Default 0.15 - How much noise to add to NVG image. (0 = none, 0.5 = insane)
#define gen_3_scintillation_constant float (0.9992f) 	// Default 0.9992 - The closer the number is to 1.00000, the less scintillation effect.

// EXAMPLE COLOR SCHEMES:
//  (0.7,1,0.6) - gen 1 soft green
//	(0.5,1,0.4) - gen 2 hard green
//  (0.2,1,0.9) - gen 3 blueish
//	(1.0,1.0,1.0) - black and white
// 	(1.0,0.7,0.1) - yellow or amber color

///////////////////////////////////////////////////////
// DEFINE NVG MASK (Credit to LVutner for huge assistance in designing the functions)
///////////////////////////////////////////////////////
float compute_lens_mask(float2 masktc, float num_tubes)
{
    float tube_radius = ((pnv_param_1.y));

    float2 single_tube_centered = float2(0.5f, -0.5f + ((pnv_param_1.x) / 100));
    float2 single_tube_offset_left  = float2(0.25f, -0.5f + ((pnv_param_1.x) / 100));		// Single tube screen position (0.5, 0.5 is centered)
    float2 single_tube_offset_right = float2(0.75f, -0.5f + ((pnv_param_1.x) / 100));	// Single tube screen position (0.5, 0.5 is centered)

    float2 dual_tube_offset_1 = float2(0.25f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for dual tube left eye
    float2 dual_tube_offset_2 = float2(0.75f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for dual tube right eye

    float2 quad_tube_offset_1 = float2(0.05f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube left outer tube
    float2 quad_tube_offset_2 = float2(0.3f, -0.5f + ((pnv_param_1.x) / 100));		// Offset for quad tube left inner tube
    float2 quad_tube_offset_3 = float2(0.7f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube right inner tube
    float2 quad_tube_offset_4 = float2(0.95f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube right outer tube


	float lua_param_flip_down = (pnv_param_1.x);
	lua_param_flip_down = clamp(5 - (lua_param_flip_down / 20.0f),1.0f,5.0f);
	masktc.y = masktc.y * lua_param_flip_down;

	if (num_tubes > 0.99f && num_tubes < 1.01f) // One tube centered
		{
			return step(distance(masktc,single_tube_centered), tube_radius);
		}
	else if (num_tubes > 1.09f && num_tubes < 1.11f) // One tube left offset
		{
			return step(distance(masktc,single_tube_offset_left), tube_radius);
		}
	else if (num_tubes > 1.19f && num_tubes < 1.21f) // One tube right offset
		{
			return step(distance(masktc,single_tube_offset_right), tube_radius);
		}
	else if (num_tubes > 1.99f && num_tubes < 2.01f) // Two tubes
		{
			if ( (step(distance(masktc,dual_tube_offset_1), tube_radius) == 1) || (step(distance(masktc,dual_tube_offset_2), tube_radius) == 1))
				{
				return 1.0f;
				}
			else
				{
				return 0.0f;
				}
		}
	else if (num_tubes > 3.99f && num_tubes < 4.01f) // Four Tubes
		{
		if  (((step(distance(masktc,quad_tube_offset_1), tube_radius) == 1) || (step(distance(masktc,quad_tube_offset_2), tube_radius) == 1)) || ((step(distance(masktc,quad_tube_offset_3), tube_radius) == 1) || (step(distance(masktc,quad_tube_offset_4), tube_radius) == 1)))
				{
				return 1.0f;
				}
			else
				{
				return 0.0f;
				}
		}
	else
	{
		return 0.0f;
	}
}


///////////////////////////////////////////////////////
// VIGNETTE CALCULATOR (USED IN NVG AS WELL AS BLOOM PHASES TO DARKEN EDGES OF SHIT)
///////////////////////////////////////////////////////
float calc_vignette (float num_tubes, float2 tc, float vignette_amount)
{
    float tube_radius = ((pnv_param_1.y));

    float2 single_tube_centered = float2(0.5f, -0.5f + ((pnv_param_1.x) / 100));
    float2 single_tube_offset_left  = float2(0.25f, -0.5f + ((pnv_param_1.x) / 100));		// Single tube screen position (0.5, 0.5 is centered)
    float2 single_tube_offset_right = float2(0.75f, -0.5f + ((pnv_param_1.x) / 100));	// Single tube screen position (0.5, 0.5 is centered)

    float2 dual_tube_offset_1 = float2(0.25f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for dual tube left eye
    float2 dual_tube_offset_2 = float2(0.75f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for dual tube right eye

    float2 quad_tube_offset_1 = float2(0.05f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube left outer tube
    float2 quad_tube_offset_2 = float2(0.3f, -0.5f + ((pnv_param_1.x) / 100));		// Offset for quad tube left inner tube
    float2 quad_tube_offset_3 = float2(0.7f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube right inner tube
    float2 quad_tube_offset_4 = float2(0.95f, -0.5f + ((pnv_param_1.x) / 100));			// Offset for quad tube right outer tube


	float vignette;
	float2 corrected_texturecoords = aspect_ratio_correction(tc);

	float lua_param_flip_down = (pnv_param_1.x);
	lua_param_flip_down = clamp(5 - (lua_param_flip_down / 20.0f),1.0f,5.0f);

	corrected_texturecoords.y = corrected_texturecoords.y * lua_param_flip_down;

	if (num_tubes > 0.99f && num_tubes < 1.01f)
	{
		float gen1_vignette = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,single_tube_centered)),3);
		vignette = 1.0 - (1.0 - gen1_vignette); // apply vignette
	}
	else if (num_tubes > 1.09f && num_tubes < 1.11f)
	{
		float gen1_vignette = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,single_tube_offset_left)),3);
		vignette = 1.0 - (1.0 - gen1_vignette); // apply vignette
	}

	else if (num_tubes > 1.19f && num_tubes < 1.21f)
	{
		float gen1_vignette = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,single_tube_offset_right)),3);
		vignette = 1.0 - (1.0 - gen1_vignette); // apply vignette
	}
	else if (num_tubes > 1.99f && num_tubes < 2.01f)
	{
		float gen2_vignette_1 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,dual_tube_offset_1)),3);
		float gen2_vignette_2 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,dual_tube_offset_2)),3);
		vignette = 1.0 - ((1.0 - gen2_vignette_1) * (1.0 - gen2_vignette_2)); // apply vignette
	}
	else if (num_tubes > 3.99f && num_tubes < 4.01f)
	{
		float gen3_vignette_1 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,quad_tube_offset_1)),3);
		float gen3_vignette_2 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,quad_tube_offset_2)),3);
		float gen3_vignette_3 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,quad_tube_offset_3)),3);
		float gen3_vignette_4 = pow(smoothstep(tube_radius,tube_radius-vignette_amount, distance(corrected_texturecoords,quad_tube_offset_4)),3);
		vignette = 1.0 - ((1.0 - gen3_vignette_1) * (1.0 - gen3_vignette_2) * (1.0 - gen3_vignette_3) * (1.0 - gen3_vignette_4)); // apply vignette
	}
	return vignette;
}
