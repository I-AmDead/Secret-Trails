/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 17
 * @ Description: Rain Shader - VS
 * @ Modified time: 2023-06-22 20:16
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"

// Vertex Struct
struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 HPos : SV_Position;
};

uniform float4x4 mVPTexgen;

VSOutput main(v_TL I)
{
    VSOutput O;

    // Basic Stuff
    O.HPos = mul(m_WVP, I.P);
    O.Tex0 = I.Tex0;

    // Screen Space Data
    O.Tex1 = mul(mVPTexgen, I.P);
    O.Tex1.z = O.HPos.z;

    return O;
}