#include "common\common.h"
#include "common\shadow.h"

float4 main(p_screen_volume I) : SV_Target
{
    if (Ldynamic_color.w == 0.0)
        return 0;

    uint2 pixel_coords = uint2(I.HPos.xy);
    uint offset = (pixel_coords.x ^ pixel_coords.y) << 1u;
    float step_offset = float((offset & 4u | pixel_coords.y & 2u) >> 1u | (offset & 2u | pixel_coords.y & 1u) << 2u) * .0625;

    float2 tex_coords = I.Tex0.xy / I.Tex0.w * float2(0.5, -0.5) + 0.5;
    float2 screen_pixel_coords = tex_coords * screen_res.xy;

    float depth = gbuffer_depth(tex_coords);
    depth = depth < 1e-4 ? 10000.0 : depth;
    depth = min(depth, I.HPos.w);

    float3 view_space_pos = float3(depth * (screen_pixel_coords * pos_decompression_params.zw - pos_decompression_params.xy), depth);
    float3 world_pos = mul(m_inv_V, float4(view_space_pos, 1.0)).xyz;

    uint num_steps = 8; // Количество шагов луча
    float ray_length = length(world_pos - eye_position) / num_steps;
    float3 ray_dir = normalize(world_pos - eye_position);
    float3 step_vector = ray_dir * ray_length;

    float3 current_pos = eye_position + step_vector * step_offset;
    
    float total_light = 0.0;

    [loop] for (uint step = 0; step < num_steps; ++step)
    {
        float4 shadow_proj = mul(m_shadow, float4(current_pos, 1.0));
        shadow_proj /= shadow_proj.w;

        float shadow_term = s_smap.SampleCmpLevelZero(smp_smap, shadow_proj.xy, shadow_proj.z + 2e-4).x;

        float3 to_light = Ldynamic_pos.xyz - current_pos.xyz;
        float dist_to_light_sq = dot(to_light, to_light);

        float attenuation = saturate(1.0 - dist_to_light_sq * Ldynamic_pos.w);
        float direction_factor = saturate(dot(-Ldynamic_dir.xyz, to_light * rsqrt(dist_to_light_sq)) + Ldynamic_dir.w);
        attenuation *= direction_factor;
        total_light += shadow_term * attenuation;
        current_pos += step_vector;
    }

    total_light *= length(step_vector);
    total_light = 1.0 - exp(-total_light / 8.0);

    return float4(total_light * Ldynamic_color.xyz, 0.0);
}