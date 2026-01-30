#include "common\common.h"

uniform Texture2D samplero_pepero;

float3 main(float2 Tex0 : TEXCOORD0) : SV_TARGET { return samplero_pepero.Sample(smp_nofilter, Tex0).rgb; }