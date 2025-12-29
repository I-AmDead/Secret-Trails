#include "common\common.h"
#include "common\skin.h"

v2p_bumped _main(v_model I, float3 psp)
{
    float4 w_pos = I.P;

    // Eye-space pos/normal
    v2p_bumped O;
    O.hpos = mul(m_WVP, w_pos);
    O.hpos_curr = O.hpos;
    O.hpos_old = mul(m_WVP_old, I.P_old);
    O.hpos.xy = get_taa_jitter(O.hpos);
    float2 tc = I.tc;
    float3 Pe = mul(m_WV, w_pos);
    O.tcdh = float4(tc.xyyy);

    //  Hemi cube lighting
    float3 Nw = mul((float3x3)m_W, (float3)I.N);
    float3 hc_pos = (float3)hemi_cube_pos_faces;
    float3 hc_neg = (float3)hemi_cube_neg_faces;
    float3 hc_mixed = (Nw < 0) ? hc_neg : hc_pos;
    float hemi_val = dot(hc_mixed, abs(Nw));
    hemi_val = saturate(hemi_val);

    O.position = float4(Pe, hemi_val); // Use L_material.x for old behaviour;

    // Calculate the 3x3 transform from tangent space to eye-space
    float3 N = I.N; // just scale (assume normal in the -.5f, .5f)
    float3 T = I.T; //
    float3 B = I.B; //
    float3x3 xform = mul((float3x3)m_WV, float3x3(2 * T.x, 2 * B.x, 2 * N.x, 2 * T.y, 2 * B.y, 2 * N.y, 2 * T.z, 2 * B.z, 2 * N.z));

    // Feed this transform to pixel shader
    O.M1 = xform[0];
    O.M2 = xform[1];
    O.M3 = xform[2];

#ifdef USE_TDETAIL
    O.tcdbump = O.tcdh * dt_params; // dt tc
#endif

    // HUD Rain drops - SSS Update 17
    // https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders/
    if (!all(psp))
        O.RDrops.xyz = I.P.xyz;
    else
        O.RDrops.xyz = psp;

    O.RDrops.w = Nw.y; // Normal-Y [ World Space ]

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
v2p_bumped main(v_model v) { return _main(v, 0); }
#endif

#ifdef SKIN_0
v2p_bumped main(v_model_skinned_0 v) { return _main(skinning_0(v), v.P); }
#endif

#ifdef SKIN_1
v2p_bumped main(v_model_skinned_1 v) { return _main(skinning_1(v), v.P); }
#endif

#ifdef SKIN_2
v2p_bumped main(v_model_skinned_2 v) { return _main(skinning_2(v), v.P); }
#endif

#ifdef SKIN_3
v2p_bumped main(v_model_skinned_3 v) { return _main(skinning_3(v), v.P); }
#endif

#ifdef SKIN_4
v2p_bumped main(v_model_skinned_4 v) { return _main(skinning_4(v), v.P); }
#endif
