#ifndef LMODEL_H
#define LMODEL_H

#include "common\common.h"
#include "common\common_brdf.h"
#include "common\pbr_brdf.h"

float3 compute_lighting(float3 N, float3 V, float3 L, float4 alb_gloss, float mat_id)
{
    bool m_terrain = abs(mat_id - 0.95) <= 0.04f;
    if (m_terrain)
        mat_id = 0;

    float3 albedo = calc_albedo(alb_gloss, mat_id);
    float3 specular = calc_specular(alb_gloss, mat_id);
    float rough = calc_rough(alb_gloss.a, mat_id);
    calc_foliage(albedo.rgb, specular, rough, alb_gloss, mat_id);

    float3 light = Lit_BRDF(rough, albedo, specular, V, N, L);

    if (abs(mat_id - MAT_FLORA) <= MAT_FLORA_ELIPSON)
    {
        float3 subsurface = SSS(N, V, L);
        light += subsurface * albedo;
    }

    return light;
}

float3 plight_infinity(float m, float3 pnt, float3 normal, float4 c_tex, float3 light_direction)
{
    float3 N = normalize(normal);
    float3 V = normalize(-pnt);
    float3 L = normalize(-light_direction);

    float3 light = compute_lighting(N, V, L, c_tex, m);

    return light;
}

float3 plight_local(float m, float3 pnt, float3 normal, float4 c_tex, float3 light_position, float light_range_rsq, out float rsqr)
{
    float atteps = 0.1f;

    float3 L2P = pnt - light_position;
    rsqr = dot(L2P, L2P);
    rsqr = max(rsqr, atteps);

    float r2 = rsqr * light_range_rsq * 1.00f; // 0.85f = slightly longer, softer reach
    float att = (1.0f - r2) / (3.0f * r2 + 1.0f);
    att = saturate(att);
    att = SRGBToLinear(att);

    float3 N = normalize(normal);
    float3 V = normalize(-pnt);
    float3 L = normalize(-L2P);

    float3 light = compute_lighting(N, V, L, c_tex, m);

    return light * att;
}

float3 specular_phong(float3 pnt, float3 normal, float3 light_direction)
{
    float3 H = normalize(pnt + light_direction);
    float nDotL = saturate(dot(normal, light_direction));
    float nDotH = saturate(dot(normal, H));
    float nDotV = saturate(dot(normal, pnt));
    float lDotH = saturate(dot(light_direction, H));

    return L_sun_color.rgb * Lit_Specular(nDotL, nDotH, nDotV, lDotH, 0.02, 0.1);
}


half4 blendp(half4 value, float4 tcp) { return value; }

half4 blend(half4 value, float2 tc) { return value; }

#endif