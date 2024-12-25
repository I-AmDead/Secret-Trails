/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 19
 * @ Description: Trees - Trunk
 * @ Modified time: 2023-12-16 13:58
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common.h"
#include "check_screenspace.h"

cbuffer dynamic_tree
{
    uniform float3x4 m_xform;
    uniform float3x4 m_xform_v;

    uniform float4 consts; // {1/quant,1/quant,???,???}

    uniform float4 c_scale;
    uniform float4 c_bias;
    uniform float2 c_sun; // x=*, y=+
}

#ifdef SSFX_WIND
#include "screenspace_wind.h"
#endif

v2p_flat main(v_tree I)
{
    I.Nh = unpack_D3DCOLOR(I.Nh);
    I.T = unpack_D3DCOLOR(I.T);
    I.B = unpack_D3DCOLOR(I.B);

    v2p_flat o;

    // Transform to world coords
    float3 pos = mul(m_xform, I.P);

    float base = m_xform._24; // take base height from matrix
    float H = pos.y - base; // height of vertex (scaled, rotated, etc.)

#if !defined(SSFX_WIND) || defined(DISABLE_WIND)
    float4 f_pos = float4(pos.xyz, 1);
    float4 f_pos_previous = f_pos;
#else
    wind_setup wset = ssfx_wind_setup();
    float2 wind_result = ssfx_wind_tree_trunk(pos, H, wset).xy;
    float4 f_pos = float4(pos.x + wind_result.x, pos.y, pos.z + wind_result.y, 1);

    wind_setup wset_old = ssfx_wind_setup(true);
    float2 wind_result_old = ssfx_wind_tree_trunk(pos, H, wset_old, true).xy;
    float4 f_pos_previous = float4(pos.x + wind_result_old.x, pos.y, pos.z + wind_result_old.y, 1);
#endif

    // Final xform
    float3 Pe = mul(m_V, f_pos);
    float hemi = I.Nh.w * c_scale.w + c_bias.w;
    // float hemi = I.Nh.w;
    o.hpos = mul(m_VP, f_pos);

    /////////////
    o.hpos_old = mul(m_VP_old, f_pos_previous);
    o.hpos_curr = o.hpos;
    o.hpos.xy = get_taa_jitter(o.hpos);
    /////////////

    o.N = mul((float3x3)m_xform_v, unpack_bx2(I.Nh));
    o.tcdh = float4((I.tc * consts).xyyy);
    o.position = float4(Pe, hemi);

#ifdef USE_GRASS_WAVE
    o.tcdh.z = 1.f;
#endif

#ifdef USE_TDETAIL
    o.tcdbump = o.tcdh * dt_params; // dt tc
#endif

    return o;
}
