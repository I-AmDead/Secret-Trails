#include "common\common.h"

Texture2D rt_tempzb;

float main(float4 HPos : SV_Position) : SV_Depth
{
    return rt_tempzb.Load(int3(HPos.xy, 0)).x;
}