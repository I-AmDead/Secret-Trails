/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 20
 * @ Description: Terrain Shader ( Shadows )
 * @ Modified time: 2024-01-13 22:30
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_shadow_direct main(float4 P : POSITION)
{
    v2p_shadow_direct O;

    // Apply a small offset to avoid the Parallax depth offset.
    float4 pos = P;
    pos.y -= 0.1f;

    O.HPos = mul(m_WVP, pos);

    return O;
}
