#ifndef HMODEL_H
#define HMODEL_H
#define CUBE_MIPS 6

#include "common\pbr_cubemap_check.h"

TextureCube env_s0;
TextureCube env_s1;

uniform float4 env_color;

void hmodel(out float3 hdiffuse, out float3 hspecular, float m, float h, float4 albedo, float3 Pnt, float3 normal)
{
    bool m_terrain = abs(m - 0.95) <= 0.04f;
    bool m_flora = abs(m - 0.15) <= 0.04f;
    if (m_terrain)
        m = 0;

    albedo.rgb = calc_albedo(albedo, m);
    float3 specular = calc_specular(albedo, m);
    float rough = calc_rough(albedo.a, m);
    calc_foliage(albedo.rgb, specular, rough, albedo, m);

    float roughCube = rough;

    // float RoughMip = roughCube * CUBE_MIPS;
    float RoughMip = pow(roughCube, 0.6) * CUBE_MIPS;
    // normal vector
    normal = normalize(normal);
    float3 nw = mul(m_inv_V, normal);

    // view vector
    Pnt = normalize(Pnt);
    float3 v2Pnt = mul(m_inv_V, Pnt);

    // normal remap
    float3 nwRemap = nw;
    float3 vnormabs = abs(nwRemap);
    float vnormmax = max(vnormabs.x, max(vnormabs.y, vnormabs.z));
    nwRemap /= vnormmax;
    if (nwRemap.y < 0.999)
        nwRemap.y = nwRemap.y * 2 - 1;

    // reflection vector
    float3 vreflect = reflect(v2Pnt, nw);
    float3 vreflectRemap = vreflect;
    float3 vreflectabs = abs(vreflectRemap);
    float vreflectmax = max(vreflectabs.x, max(vreflectabs.y, vreflectabs.z));
    vreflectRemap /= vreflectmax;
    if (vreflectRemap.y < 0.999)
        vreflectRemap.y = vreflectRemap.y * 2 - 1;

    // normalize
    nwRemap = normalize(nwRemap);
    vreflectRemap = normalize(vreflectRemap);
    vreflectRemap = getSpecularDominantDir(nwRemap, vreflectRemap, rough);

    // Valve style ambient cube to prevent seams
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

    // specular color
    float3 e0s = env_s0.SampleLevel(smp_base, vreflectRemap, RoughMip);
    float3 e1s = env_s1.SampleLevel(smp_base, vreflectRemap, RoughMip);

    // lerp
    float3 env_d = lerp(e0d, e1d, env_color.w);
    float3 env_s = lerp(e0s, e1s, env_color.w);

    float hscale = h;

    float4 light = float4(hscale, hscale, hscale, hscale);

    float3 env_col = env_color.rgb;

    env_d *= env_col;
    env_s *= env_col;

    // lightmap ambient
    env_d *= light.xxx;
    env_s *= light.www;

    // ambient color
    float3 amb_col = L_ambient.rgb;
    env_d += amb_col;

    // [FIX] "Ambient Specular Bleed" - UPDATED BY HIPPOBOT
    // We calculate metalness here to MASK the ambient bleed.
    // Metals should rely purely on the Cubemap (env_s), not fake ambient boost?
    float metal_check = calc_metalness(albedo.rgb, m);

    float rough_ambient = smoothstep(0.1, 1.0, rough);

    // Multiply by (1.0 - metal_check) to ensure this only affects non-metals (cloth, wood, dirt)
    float metal_mask = 1.0 - (metal_check * 0.55);

    env_s += amb_col * rough_ambient * metal_mask * h * 0.4;

    env_d = SRGBToLinear(env_d);
    env_s = SRGBToLinear(env_s);

    env_s *= 1.0f - m_flora * 0.75f;

    hdiffuse = Amb_BRDF(rough, albedo, specular, env_d, env_s, -v2Pnt, nw).rgb;
    hspecular = 0;
}
#endif