#include "common\common.h"

Texture2D s_patched_normal;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float Gloss = s_patched_normal.Sample(smp_nofilter, Tex0).a;

    float rain = rain_params.x;

    float ColorIntencity = 1 - sqrt(Gloss);
    ColorIntencity = ColorIntencity + (rain / 2);

    return float4(ColorIntencity, ColorIntencity, ColorIntencity, Gloss);
}