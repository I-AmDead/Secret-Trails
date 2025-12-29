/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 19
 * @ Description: Trees - Shadows
 * @ Modified time: 2023-12-16 13:42
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"
#include "common\screenspace\check_screenspace.h"

#ifdef SSFX_WIND
#include "common\screenspace\screenspace_wind.h"
#endif

v2p_shadow_direct main(v_tree I)
{
    float3x4 m_xform = float3x4(I.m0, I.m1, I.m2);
    float4 consts = I.consts;

    v2p_shadow_direct O;

#ifdef USE_AREF
    float2 tc = (I.tc * consts).xy;
    O.tc0 = tc;
#endif

    // Transform to world coords
    float3 pos = mul(m_xform, I.P);
    float H = pos.y - m_xform._24; // height of vertex (scaled, rotated, etc.)
    float3 wind_result = 0;

#if defined(SSFX_WIND) && !defined(DISABLE_WIND)
#ifdef USE_AREF
    wind_result = ssfx_wind_tree_branches(m_xform, pos, H, tc.y, ssfx_wind_setup());
#else
    wind_result.xz = ssfx_wind_tree_trunk(m_xform, pos, H, ssfx_wind_setup()).xy;
#endif
#endif

    float4 f_pos = float4(pos.xyz + wind_result.xyz, 1);

    O.hpos = mul(m_VP, f_pos);

    return O;
}
