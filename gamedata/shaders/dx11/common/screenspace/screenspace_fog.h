/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 14.4
 * @ Description: 2 Layers fog ( Distance + Height )
 * @ Modified time: 2024-01-22 05:45
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\screenspace\settings_screenspace_FOG.h"

float SSFX_FOGGING(float Fog, float World_Py)
{
    // Height fog
    float fog_height = smoothstep(G_FOG_HEIGHT, -G_FOG_HEIGHT, World_Py) * G_FOG_HEIGHT_INTENSITY;

    // Add height fog to default distance fog.
    float fog_extra = saturate(Fog + fog_height * (Fog * G_FOG_HEIGHT_DENSITY));

    return 1.0f - fog_extra;
}

float SSFX_CALC_FOG(float3 P)
{
    float3 WorldP = mul(m_inv_V, float4(P.xyz, 1));
    float distance = length(P.xyz);
    float fog = saturate(distance * fog_params.w + fog_params.x); // Vanilla fog
    float fogheight = smoothstep(G_FOG_HEIGHT, -G_FOG_HEIGHT, WorldP.y) * G_FOG_HEIGHT_INTENSITY; // Height fog

    return saturate(fog + fogheight * (fog * G_FOG_HEIGHT_DENSITY));
}