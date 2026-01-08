#include "common\common.h"
#include "common\screenspace\screenspace_common.h"
#include "common\screenspace\screenspace_dof.h"

float4 main(p_screen I) : SV_TARGET
{
    float depth = gbuffer_depth(I.tc0);
    float3 img = s_image.Sample(smp_nofilter, I.tc0).rgb;

    return float4(SSFX_DOF(I.tc0, depth, img), 1.0);
}
