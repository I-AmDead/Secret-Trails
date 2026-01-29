/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 19
 * @ Description: Trees - Trunk
 * @ Modified time: 2023-12-16 13:58
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"
#include "common\screenspace\check_screenspace.h"

#ifdef SSFX_WIND
#include "common\screenspace\screenspace_wind.h"
#endif

v2p_flat main(v_tree I)
{
    float3x4 m_xform = float3x4(I.M0, I.M1, I.M2);
    float4 consts = I.Consts;

    I.N = unpack_D3DCOLOR(I.N);
    I.T = unpack_D3DCOLOR(I.T);
    I.B = unpack_D3DCOLOR(I.B);

    v2p_flat O;

    // Transform to world coords
    float3 pos = mul(m_xform, I.P);

    float base = m_xform._24; // take base height from matrix
    float H = pos.y - base; // height of vertex (scaled, rotated, etc.)

#if !defined(SSFX_WIND) || defined(DISABLE_WIND)
    float4 f_pos = float4(pos.xyz, 1);
    float4 f_pos_previous = f_pos;
#else
    wind_setup wset = ssfx_wind_setup();
    float2 wind_result = ssfx_wind_tree_trunk(m_xform, pos, H, wset).xy;
    float4 f_pos = float4(pos.x + wind_result.x, pos.y, pos.z + wind_result.y, 1);

    wind_setup wset_old = ssfx_wind_setup(true);
    float2 wind_result_old = ssfx_wind_tree_trunk(m_xform, pos, H, wset_old, true).xy;
    float4 f_pos_previous = float4(pos.x + wind_result_old.x, pos.y, pos.z + wind_result_old.y, 1);
#endif

    // Final xform
    float3 Pe = mul(m_V, f_pos);
    float hemi = I.N.w * consts.z + consts.w;

    /////////////
    O.hpos = mul(m_VP, f_pos);
    O.hpos_old = mul(m_VP_old, f_pos_previous);
    O.hpos_curr = O.hpos;
    O.hpos.xy = get_taa_jitter(O.hpos);
    /////////////

    float3x3 m_xform_v = mul((float3x3)m_V, (float3x3)m_xform);
    O.N = mul(m_xform_v, unpack_bx2(I.N));
    O.tcdh = float4((I.Tex0 * consts).xyyy);
    O.position = float4(Pe, hemi);

#ifdef USE_TDETAIL
    O.tcdbump = O.tcdh * dt_params;
#endif

    return O;
}
