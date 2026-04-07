/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 20
 * @ Description: LUT shader
 * @ Modified time: 2024-01-22 04:12
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#define G_ADVANCE_TRANSITION
#define G_CELLS_SIZE 32 // Width/Height of your cell

Texture2D s_lut_atlas;

uniform float4 lut_params;

float3 sample_lut_group(float4 uvs, float lut_frac, float group_offset, int groups)
{
    float2 grp_offset = float2(0.0, group_offset / groups);
    return lerp(s_lut_atlas.Sample(smp_linear, uvs.xy + grp_offset).rgb, s_lut_atlas.Sample(smp_linear, uvs.zw + grp_offset).rgb, lut_frac);
}

float3 img_lut(float3 base_col)
{
    // Get Texture Dimension
    int G_LUT_SIZE_W, G_LUT_SIZE_H, G_LUT_GROUPS;
    s_lut_atlas.GetDimensions(G_LUT_SIZE_W, G_LUT_SIZE_H);

    // Get number lut groups
    G_LUT_GROUPS = G_LUT_SIZE_H / G_CELLS_SIZE;

    // Internal
    float2 TEXEL_SIZE = float2(1.0f / G_LUT_SIZE_W, 1.0f / (G_CELLS_SIZE * G_LUT_GROUPS));
    float2 TEXEL_HALF = float2(TEXEL_SIZE.xy / 2.0f);
    float TEXEL_FIX = TEXEL_SIZE.y * G_LUT_GROUPS;

    // Prepare LUT UVs
    float3 cells = base_col * G_CELLS_SIZE - base_col;
    float lut_frac = frac(cells.b);
    cells.rg = TEXEL_HALF + cells.rg * TEXEL_SIZE;
    cells.r += (cells.b - lut_frac) * TEXEL_FIX;

    // Final LUT UVs
    float4 uvs = float4(cells.rg, cells.r + TEXEL_FIX, cells.g);

    // Sample LUT
    float3 lut_col = sample_lut_group(uvs, lut_frac, lut_params.y, G_LUT_GROUPS);

#ifdef G_ADVANCE_TRANSITION
    // Sample LUT
    float3 second_lut = sample_lut_group(uvs, lut_frac, lut_params.z, G_LUT_GROUPS);
    lut_col = lerp(lut_col, second_lut, lut_params.w);
#endif

    return lerp(base_col, lut_col, lut_params.x);
}