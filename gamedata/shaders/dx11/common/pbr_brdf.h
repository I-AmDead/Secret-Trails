#include "common\pbr_settings.h" //load settings files

#define PI 3.14159265359

uniform float4 ssfx_lightsetup_1;

float calc_metalness(float alb_gloss, float material_ID)
{
    float metallerp = max(0.0, (material_ID * 4) - 0.5) / 4;
    float metalness = saturate(material_ID - 0.75 - 0.001) > 0 ? 1 : 0;
    float metal_thres = pow(METALNESS_THRESHOLD, exp2(metallerp));
    float metal_soft = metal_thres * 0.9;
    metalness *= saturate((alb_gloss - (metal_thres - metal_soft)) / ((metal_thres + metal_soft) - (metal_thres - metal_soft)));

    return metalness;
}

float3 Soft_Light(float3 base, float3 blend) { return (blend <= 0.5) ? base - (1 - 2 * blend) * base * (1 - base) : base + (2 * blend - 1) * (sqrt(base) - base); }

float3 calc_albedo_boost(float3 albedo)
{
    float3 blend = lerp(0.5, 1 - dot(albedo, LUMINANCE_VECTOR), ALBEDO_BOOST);

    return Soft_Light(albedo, blend);
}

float4 _ls()
{
    float4 ls = ssfx_lightsetup_1;
    if (abs(ls.x) + abs(ls.y) < 1e-5)
    {
        ls.x = 1.0;
        ls.y = 0.0;
    }

    return float4(ls.x, saturate(ls.y), 0, 0);
}

float3 calc_albedo(float4 albedo, float material_ID)
{
    float metalness = calc_metalness(albedo.a, material_ID);
    albedo.rgb = calc_albedo_boost(albedo.rgb);
    float3 screen_contrib = albedo.rgb;

    screen_contrib = (1 - (1 - screen_contrib) * (1 - screen_contrib)) - lerp(dot(screen_contrib, LUMINANCE_VECTOR), screen_contrib, 0.5);

    albedo.rgb = SRGBToLinear(albedo.rgb);
    screen_contrib = SRGBToLinear(screen_contrib);

    float3 albedo_metal = screen_contrib;

    return saturate(lerp(albedo.rgb, albedo_metal, metalness) * ALBEDO_AMOUNT);
}

float3 calc_specular(float4 albedo, float material_ID)
{
    float metalness = calc_metalness(albedo.a, material_ID);

    float3 specular = float3(SPECULAR_BASE, SPECULAR_BASE, SPECULAR_BASE); // base fresnel to tweak

    float3 specular_metal = albedo.rgb; // metal uses diffuse for specular
    specular_metal = calc_albedo_boost(specular_metal); // boost albedo
    specular_metal = SRGBToLinear(specular_metal);

    // tweaks for specular boost
    material_ID = saturate(material_ID * 1.425);
    albedo.a = sqrt(albedo.a);

    float specular_boost = (material_ID * 2 - 1) + (albedo.a * 2 - 1); //-2.0 - +2.0 range
    specular_boost = exp2(SPECULAR_RANGE * specular_boost);
    specular_boost = pow(specular_boost, SPECULAR_POW);

    specular *= specular_boost;

    return saturate(lerp(specular, specular_metal, metalness));
}

float calc_rough(float albedo_gloss, float material_ID)
{
    float metalness = calc_metalness(albedo_gloss, material_ID);
    albedo_gloss = pow(albedo_gloss, ROUGHNESS_POW - (metalness * METAL_BOOST));

    float roughpow = 0.5 / max(0.001, 1 - Ldynamic_color.w);
    float rough = pow(lerp(ROUGHNESS_HIGH, ROUGHNESS_LOW, albedo_gloss), roughpow);
    rough = saturate(rough * rough);
    rough = max(rough, 0.035f);

    return rough;
}

void calc_rain(inout float3 albedo, inout float3 specular, inout float rough, in float4 alb_gloss, in float material_ID, in float rainmask)
{
    float wetness = saturate(smoothstep(0.1, 0.9, rain_params.x * rainmask));

    float porosity = 1 - saturate(material_ID * 1.425);

    float factor = lerp(1, 0.2, porosity);

    albedo *= lerp(1, factor, wetness);
    rough = lerp(0.001, rough, lerp(1, factor, wetness));
    specular = lerp(specular, 0.02, wetness);
}

void calc_foliage(inout float3 albedo, inout float3 specular, inout float rough, in float4 alb_gloss, in float mat_id)
{
    specular = (abs(mat_id - MAT_FLORA) <= MAT_FLORA_ELIPSON) ? alb_gloss.g * 0.02 : specular;
}

float F_Shlick(float f0, float f90, float vDotH) { return lerp(f0, f90, pow(1 - vDotH, 5)); }

float3 F_Shlick(float3 f0, float3 f90, float vDotH) { return lerp(f0, f90, pow(1 - vDotH, 5)); }

float3 getSpecularDominantDir(float3 N, float3 R, float roughness)
{
    float smoothness = saturate(1 - roughness);
    float lerpFactor = smoothness * (sqrt(smoothness) + roughness);

    return lerp(N, R, lerpFactor);
}

float HorizonOcclusion(float3 N, float3 R)
{
    float horizon = saturate(1.0 + 1.2 * dot(R, N));

    return horizon * horizon;
}

#include "common\pbr_brdf_blinn.h" //brdf
#include "common\pbr_brdf_ggx.h" //brdf

float Lit_Burley(float nDotL, float nDotV, float vDotH, float rough)
{
    float fd90 = 0.5 + 2 * vDotH * vDotH * rough;
    float lightScatter = F_Shlick(1, fd90, nDotL);
    float viewScatter = F_Shlick(1, fd90, nDotV);

    return (lightScatter * viewScatter) / PI;
}

float Lambert_Source(float nDotL, float rough)
{
    float exponent = lerp(1.4, 0.6, rough);

    return (pow(nDotL, exponent) * ((exponent + 1.0) * 0.5)) / max(1e-5, PI * nDotL);
}

float Lit_Diffuse(float nDotL, float nDotV, float vDotH, float rough)
{
#ifdef USE_BURLEY_DIFFUSE
    return Lit_Burley(nDotL, nDotV, vDotH, rough);
#else
    return Lambert_Source(nDotL, rough);
#endif
}

float3 Lit_Specular(float nDotL, float nDotH, float nDotV, float vDotH, float3 f0, float rough)
{
#ifdef USE_GGX_SPECULAR
    return Lit_GGX(nDotL, nDotH, nDotV, vDotH, f0, rough);
#else
    return Lit_Blinn(nDotL, nDotH, nDotV, vDotH, f0, rough);
#endif
}

float specAA_rough(float3 N, float rough, float nDotL, float vDotH)
{
    float3 dnx = ddx(N), dny = ddy(N);
    float variance = dot(dnx, dnx) + dot(dny, dny);
    float add_r = saturate(variance * 0.30);
    float r2 = rough * rough + add_r;

    return saturate(sqrt(r2));
}

float3 Lit_BRDF(float rough_in, float3 albedo, float3 f0, float3 V, float3 N, float3 L)
{
    float3 H = normalize(V + L);
    float nDotL = saturate(dot(N, L));
    float nDotH = saturate(dot(N, H));
    float nDotV = max(1e-5f, dot(N, V));
    float vDotH = saturate(dot(V, H));

    float rough = specAA_rough(N, rough_in, nDotL, vDotH);

    float3 diffuse_term = Lit_Diffuse(nDotL, nDotV, vDotH, rough).rrr;
    diffuse_term *= albedo;

    // Specular
    float rough_sun = max(rough, 0.004f);
    float3 specular_term = Lit_Specular(nDotL, nDotH, nDotV, vDotH, f0, rough_sun);

    // Horizon falloff
    float g = saturate(min(nDotV, nDotL));
    float horizon = lerp(0.4f, 1.0f, smoothstep(0.15f, 0.4f, g));
    specular_term *= horizon;

    // Specular color
    float4 ls = _ls();
    float specStrength = max(ls.x, 0.0f);
    float specColorMix = saturate(ls.y);

    float3 light = saturate(Ldynamic_color.rgb);
    float li = max(1e-3f, max(light.r, max(light.g, light.b)));
    float3 lnorm = light / li;

    float3 specColor = lerp(1.0.xxx, lnorm, specColorMix);

    specular_term *= specStrength;
    specular_term *= specColor;

    return (diffuse_term + specular_term) * nDotL * PI;
}

float EnvBurley(float roughness, float NV)
{
    float d0 = 0.97619 - 0.488095 * pow(1.0 - NV, 5.0);
    float d1 = 1.55754 + (-2.02221 + (2.56283 - 1.06244 * NV) * NV) * NV;

    return lerp(d0, d1, roughness);
}

float Amb_Diffuse(float3 f0, float rough, float nDotV)
{
#ifdef USE_BURLEY_DIFFUSE
    return EnvBurley(rough, nDotV);
#else
    return 1.0;
#endif
}

float3 Amb_Specular(float3 f0, float rough, float nDotV)
{
#ifdef USE_GGX_SPECULAR
    return EnvGGX(f0, rough, nDotV);
#else
    return EnvBlops2(f0, rough, nDotV);
#endif
}

float3 Amb_BRDF(float rough, float3 albedo, float3 f0, float3 env_d, float3 env_s, float3 V, float3 N)
{
    float DotNV = dot(N, V);
    float nDotV = max(1e-5f, dot(N, V));

    float3 diffuse_term = Amb_Diffuse(f0, rough, nDotV);
    diffuse_term *= env_d * albedo;

    float3 specular_term = Amb_Specular(f0, rough, nDotV);
    specular_term *= env_s;

    float3 R = reflect(-V, N);
    specular_term *= HorizonOcclusion(N, R);

    return diffuse_term + specular_term;
}