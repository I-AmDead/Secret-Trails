// Screen Space Shaders - Shadows File
// Update 7 [ 2022/06/27 ]

#include "screenspace_common.h"
#include "settings_screenspace_SSS.h"

// Internal values. [ Don't touch? ]
static const float3 SSFX_sss_offset[3] = {
	float3(1.011f, 1.011f, 1.011),
	float3(1.022f, 1.022f, 1.022),
	float3(1.033f, 1.033f, 1.033)
};

static const float SSFX_sss_len[4] = {
	float(0.025f),
	float(0.035f),
	float(0.045f),
	float(0.055f),
};

static const int SSFX_sss_steps[4] = {
	int(8),
	int(12),
	int(16),
	int(20)
};

float SSFX_SSS(float3 P, float3 ray_dir, int steps, float len_multy, float offset, float occ, uint iSample)
{
	// Initialize Ray
	RayTrace sss_ray = SSFX_ray_init(P, ray_dir, len_multy, steps, offset );
	
    // Ray march
	[unroll (steps)]
    for (int i = 0; i < steps; i++)
    {
        // Ray out of screen...
        if (!SSFX_is_valid_uv(sss_ray.r_pos))
            return 0.0f;
       
        // Ray intersect check ( x = dist | y = tc depth )
		float3 ray_check = SSFX_ray_intersect(sss_ray, iSample);
		
		// Negative: Ray is closer to the camera ( not occluded )
        // Positive: Ray is beyond the depth sample ( occluded )
		if (ray_check.x > G_SSS_DETAILS && !is_sky(ray_check.y))
		{
			// Fade based on ray distance from occluded pixel and max length of ray
			return smoothstep(sss_ray.r_length, sss_ray.r_length * G_SSS_FADE, ray_check.z) * occ;
		}
        
        // Step the ray
        sss_ray.r_pos += sss_ray.r_step;
    }
	
    return 0.0f;
}


float SSFX_ScreenSpaceShadows(float3 P, float2 tc, uint iSample)
{
	// Render limit
	if (length(P.xyz) > G_SSS_MAXDISTANCE)
		return 1.0;
	
	// Light vector
	float3 L_dir = mul(m_V, float4(-normalize(L_sun_dir_w), 0)).xyz;
	
	// Jitter to fill between steps
	float2 jitter = (jitter0.Sample( smp_linear, tc * 2.5f ).xy + 0.5f ) * 2.4f;
	
	// Shadow accumulator value
	float S = 0;

#if (G_SSS_REFINE_PASSES > 0 )
	// Alpha for each pass
	float alpha = 1.0f / ( G_SSS_REFINE_PASSES + 1 );
	
	// Base shadow
	S += SSFX_SSS(P, L_dir, SSFX_sss_steps[G_SSS_QUALITY], SSFX_sss_len[G_SSS_QUALITY], jitter.x, alpha, iSample);
	
	// Extra Passes
	[unroll (G_SSS_REFINE_PASSES)] 
	for(int i = 0; i < G_SSS_REFINE_PASSES; i++)
    {
		S += SSFX_SSS(P * SSFX_sss_offset[i], L_dir, SSFX_sss_steps[G_SSS_QUALITY], SSFX_sss_len[G_SSS_QUALITY], jitter.y, alpha, iSample);
    }

#else
	// Base shadow
	S += SSFX_SSS(P, L_dir, SSFX_sss_steps[G_SSS_QUALITY], SSFX_sss_len[G_SSS_QUALITY], jitter.x, 1.0f, iSample);
#endif

	return 1.0f - saturate(S) * G_SSS_INTENSITY;
}