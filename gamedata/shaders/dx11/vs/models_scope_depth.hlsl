#include "common\common.h"
#include "common\skin.h"

float4 _main(v_model I)
{
    float4 HPos = mul(m_WVP, I.P);
    HPos.xy = get_taa_jitter(HPos);

    return HPos;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
float4 main(v_model I) : SV_Position { return _main(I); }
#endif

#ifdef SKIN_0
float4 main(v_model_skinned_0 I) : SV_Position { return _main(skinning_0(I)); }
#endif

#ifdef SKIN_1
float4 main(v_model_skinned_1 I) : SV_Position { return _main(skinning_1(I)); }
#endif

#ifdef SKIN_2
float4 main(v_model_skinned_2 I) : SV_Position { return _main(skinning_2(I)); }
#endif

#ifdef SKIN_3
float4 main(v_model_skinned_3 I) : SV_Position { return _main(skinning_3(I)); }
#endif

#ifdef SKIN_4
float4 main(v_model_skinned_4 I) : SV_Position { return _main(skinning_4(I)); }
#endif