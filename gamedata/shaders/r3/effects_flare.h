#include "ogse_functions.h"

Texture2D s_noise;

#define uGhostCount 6
#define uGhostSpacing 0.35
#define uGhostThreshold 0.7
#define uHaloRadius 0.35
#define uHaloThickness 0.065

float4 get_sun_uv()
{
    // Dist to the sun
    float sun_dist = FARPLANE / (sqrt(1.0f - L_sun_dir_w.y * L_sun_dir_w.y));

    // Sun pos
    float3 sun_pos_world = sun_dist * L_sun_dir_w + eye_position;
    float4 sun_pos_projected = mul(m_VP, float4(sun_pos_world, 1.0f));
    float4 sun_pos_screen = proj_to_screen(sun_pos_projected) / sun_pos_projected.w;

	return sun_pos_screen;
}

float3 fetch_lf(float2 uv, float size)
{
    uv -= 0.5;
    uv *= float2(screen_res.x * screen_res.w, 1.0);

    float2 circle_pos = get_sun_uv().xy; //see above
    circle_pos -= 0.5;
    circle_pos *= float2(screen_res.x * screen_res.w, 1.0);
 
    float circle = smoothstep(size, 0.0, length(uv+circle_pos));
    return float3(1.0,0.656,0.3) * circle;
}

float generate_starburst(float2 uv)
{
    uv *= float2(screen_res.x /screen_res.y, 1.0);
    float angle = atan(uv.y / uv.x);
    float2 sb_uv = float2(cos(angle), sin(angle)) / 3.14;
    float sb_tex = s_noise.Sample(smp_linear, sb_uv * 64.).x;
    return smoothstep(0.0, sb_tex, length(uv / 4.)) * length(uv / 2.); //soften it a little bit
}

//generate ghosts n shit
float4 generate_ghosts(float2 uv)
{
    //Draw multiple 'ghosts'
    float3 accumulated_ghosts = (float3)0.0;
    {
        uv = 1.0 - uv;
        float2 ghostVec = (0.5 - uv) * uGhostSpacing;

        //initial flare (directly on the sun)
        //replace it with something else maybe
        accumulated_ghosts += fetch_lf(uv, 0.055).xyz;

        //additional ghosts
        for (int i = 1; i < uGhostCount; ++i) 
        {
            float2 suv = uv + ghostVec * float(i);
            float ghost_intensity = float(i) / float(uGhostCount);
            ghost_intensity = pow(ghost_intensity, 2.0); //so each subsequent ghost has different intensity
            float d = distance(suv, 0.5);
            float weight = 1.0 - smoothstep(0.0, 0.75, d);
            accumulated_ghosts += fetch_lf(suv, 0.025).xyz * weight;
        }
    }
    
    //Create simple halo
    float3 accumulated_halo = (float3)0.0;
    {
        float2 haloVec = 0.5 - uv;
        haloVec.x /= screen_res.y * screen_res.z;
        haloVec = normalize(haloVec);
        haloVec.x *= screen_res.y * screen_res.z;
        haloVec *= uHaloRadius;
        accumulated_halo += fetch_lf(uv + haloVec, uHaloThickness).xyz * generate_starburst(uv);
    }

    uv = 1. - uv;
    float dep = s_position.Load(int3(get_sun_uv() * screen_res.xy, 0), 0).z;

    //Add all shit together
    float4 final = float4((accumulated_ghosts + accumulated_halo) * L_sun_color, 1.0);

    float visibility = 1.0 - dep;
    if (visibility < 1.0)
        final *= 0.0;

    return final;
}