/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 11.3
 * @ Description: SSS implementation
 * @ Modified time: 2022-09-27 09:10
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "screenspace_common.h"

float SSFX_ScreenSpaceShadows(float4 P, float2 tc, uint iSample)
{
	// Light vector
	float3 L_dir = mul(m_V, float4(-normalize(L_sun_dir_w), 0)).xyz;

	// Material conditions...
	//bool mat_flora = abs(P.w - MAT_FLORA) <= 0.02f;
	bool mat_terrain = abs(P.w - 0.95f) <= 0.02f;

	// Weapons mask. Depth below or equal to G_SSDO_WEAPON_LENGTH
	bool weapon_mask = P.z >= G_SSDO_WEAPON_LENGTH;

	if (weapon_mask)
		return 1.0;
	
	// Weapon Factor.
	float pLen = length(P.z);
	float wpn_f = smoothstep(G_SSDO_WEAPON_LENGTH * 0.75f, G_SSDO_WEAPON_LENGTH, pLen);

	// Adjust Settings for weapons and scene.
	float ray_hardness	= 10.0f * G_SSDO_WEAPON_HARDNESS * (1.0 - wpn_f);
	float ray_detail	= clamp(pLen * 0.003f, G_SSS_DETAILS, 10);
	float ray_thick		= (0.3f - wpn_f * 0.23f) + (pLen * 0.001f * wpn_f);
	float ray_len		= G_SSDO_WEAPON_SHADOW_LENGTH * (1.0 - wpn_f);

	RayTrace sss_ray = SSFX_ray_init(P, L_dir, ray_len, G_SSS_STEPS, SSFX_noise(tc));

	float fade_len = 1.0f + sss_ray.r_step;
	float shadow = 0;

	[unroll (G_SSS_STEPS)]
	for (int i = 0; i < G_SSS_STEPS; i++)
	{
		// Break the march if ray go out of screen...
		if (!SSFX_is_valid_uv(sss_ray.r_pos))
			break;

		// Sample current ray pos ( x = difference | y = sample depth | z = current ray len )
		float3 depth_ray = SSFX_ray_intersect(sss_ray, iSample);
		
		// Check depth difference
		float diff = depth_ray.x;
		
		// No Sky
		diff *= depth_ray.y > SKY_EPS;

		// Disable weapons at some point to avoid wrong shadows on the ground
		if (weapon_mask)
			diff *= depth_ray.y >= 1.0f;

		// Negative: Ray is closer to the camera ( not occluded )
		// Positive: Ray is beyond the depth sample ( occluded )
		if (diff > ray_detail && diff < ray_thick)
		{
			shadow += (fade_len - depth_ray.z) * (1.0f - smoothstep( G_SSS_STEPS * G_SSS_FORCE_FADE, G_SSS_STEPS + 1, i));
		}

		// Step the ray
		sss_ray.r_pos += sss_ray.r_step;
	}

	// Calc shadow and return.
	return 1.0f - saturate(shadow * (1.0f / G_SSS_STEPS) * ray_hardness) * G_SSS_INTENSITY;
}