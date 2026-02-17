#ifndef HMODEL_H
#define HMODEL_H
#define CUBE_MIPS 5

#include "common\pbr_cubemap_check.h"

TextureCube env_s0;
TextureCube env_s1;

uniform float4 env_color;

void hmodel(out float3 hdiffuse, out float3 hspecular, float m, float h, float4 alb_gloss, float3 Pnt, float3 normal)
{
    bool m_terrain = abs(m - 0.95) <= 0.04f;
    bool m_flora = abs(m - 0.15) <= 0.04f;
    if (m_terrain)
        m = 0;

    float3 albedo = calc_albedo(alb_gloss, m);
    float3 specular = calc_specular(alb_gloss, m);
    float rough = calc_rough(alb_gloss, m);
    calc_foliage(albedo, specular, rough, alb_gloss, m);

    // Standard linear mip mapping for roughness
    float roughCube = rough;
    float RoughMip = pow(roughCube, 0.85) * CUBE_MIPS;

    normal = normalize(normal);
    float3 nw = mul(m_inv_V, normal);
    float3 nwRemap = nw;

    Pnt = normalize(Pnt);
    float3 v2Pnt = mul(m_inv_V, Pnt);

    float3 vreflect = reflect(v2Pnt, nw);
    float3 vreflectRemap = vreflect;
    nwRemap = normalize(nwRemap);
    vreflectRemap = normalize(vreflectRemap);
    vreflectRemap = getSpecularDominantDir(nwRemap, vreflectRemap, rough);

    const float Epsilon = 0.001;
    float3 nSquared = nw * nw;

    float3 e0d = 0;
    e0d += nSquared.x * (env_s0.SampleLevel(smp_base, float3(nwRemap.x, Epsilon, Epsilon), CUBE_MIPS).rgb);
    e0d += nSquared.y * (env_s0.SampleLevel(smp_base, float3(Epsilon, nwRemap.y, Epsilon), CUBE_MIPS).rgb);
    e0d += nSquared.z * (env_s0.SampleLevel(smp_base, float3(Epsilon, Epsilon, nwRemap.z), CUBE_MIPS).rgb);

    float3 e1d = 0;
    e1d += nSquared.x * (env_s1.SampleLevel(smp_base, float3(nwRemap.x, Epsilon, Epsilon), CUBE_MIPS).rgb);
    e1d += nSquared.y * (env_s1.SampleLevel(smp_base, float3(Epsilon, nwRemap.y, Epsilon), CUBE_MIPS).rgb);
    e1d += nSquared.z * (env_s1.SampleLevel(smp_base, float3(Epsilon, Epsilon, nwRemap.z), CUBE_MIPS).rgb);

    float3 e0s = env_s0.SampleLevel(smp_base, vreflectRemap, RoughMip);
    float3 e1s = env_s1.SampleLevel(smp_base, vreflectRemap, RoughMip);

    float3 env_d = lerp(e0d, e1d, env_color.w);
    float3 env_s = lerp(e0s, e1s, env_color.w);

    float hscale = h;

    float4 light = float4(hscale, hscale, hscale, hscale);

    float3 env_col = env_color.rgb;

    env_d *= env_col;
    env_s *= env_col;

    env_d *= light.xxx;
    env_s *= light.www;

    float3 amb_col = L_ambient.rgb;
    env_d += amb_col;

    // Metals should rely purely on the Cubemap (env_s), not fake ambient boost?
    float metal_check = calc_metalness(alb_gloss, m);

    // ROUGHNESS MASK (BRIGHTNESS FIX)
    float rough_mask = 1.0 - rough;
    float metal_mask = 1.0 - (metal_check * 0.1);

    env_s += amb_col * rough_mask * metal_mask * h;

    env_d = SRGBToLinear(env_d);
    env_s = SRGBToLinear(env_s);

    env_s *= 1.0f - m_flora * 0.75f;

    hdiffuse = Amb_BRDF(rough, albedo, specular, env_d, env_s, -v2Pnt, nw).rgb;
    hspecular = 0;
}
#endif