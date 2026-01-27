/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 23
 * @ Description: Glass Shader - VS
 * @ Modified time: 2025-05-10 23:25:24
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"
#include "common\skin.h"

#include "common\screenspace\check_screenspace.h"
#include "common\screenspace\screenspace_fog.h"

struct VSOutput
{
    float4 P : POSITION;
    float2 Tex0 : TEXCOORD0; // base
    float3 Tex1 : TEXCOORD1; // environment
    float3 Tex2 : TEXCOORD2;
    float3 Tex3 : TEXCOORD3;
    float4 HPos : SV_Position;
    float Fog : FOG;
};

VSOutput _main(v_model I, float3 psp)
{
    VSOutput O;

    float4 pos = I.P;
    float3 pos_w = mul(m_W, pos);
    float3 norm_w = normalize(mul(m_W, I.N));

    O.HPos = mul(m_WVP, pos); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy; // copy tc
    O.Tex1 = calc_reflection(pos_w, norm_w);

    O.Fog = saturate(calc_fogging(float4(pos_w, 1))); // fog, input in world coords
    O.Fog = SSFX_FOGGING(1.0 - O.Fog, pos.y); // Add SSFX Fog

    O.Tex2 = normalize(pos_w - eye_position);
    O.Tex3 = norm_w;

    if (!all(psp))
        O.P.xyz = pos.xyz;
    else
        O.P.xyz = psp;

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
VSOutput main(v_model I) { return _main(I, 0); }
#endif

#ifdef SKIN_0
VSOutput main(v_model_skinned_0 I) { return _main(skinning_0(I), I.P); }
#endif

#ifdef SKIN_1
VSOutput main(v_model_skinned_1 I) { return _main(skinning_1(I), I.P); }
#endif

#ifdef SKIN_2
VSOutput main(v_model_skinned_2 I) { return _main(skinning_2(I), I.P); }
#endif

#ifdef SKIN_3
VSOutput main(v_model_skinned_3 I) { return _main(skinning_3(I), I.P); }
#endif

#ifdef SKIN_4
VSOutput main(v_model_skinned_4 I) { return _main(skinning_4(I), I.P); }
#endif