/*
    Gasmask breath shader

    Credits: I AM DEAD

    /////////////////
    OGSR Engine 2026
    /////////////////
*/

#include "common\common.h"
#include "common\ogsr_gasmask_common.h"

float MaskGen(float2 uv)
{
    float breath_power = saturate(breath_size);

    float2 center = float2(0.5f, lerp(0.9f, 1.0f, breath_power));
    
    float stretchX = 0.6f;
    float stretchY = 1.5f;
    
    float2 scaledDist = (uv - center) * float2(stretchX, stretchY);
    float rawDistance = length(scaledDist);
    
    rawDistance += abs(scaledDist.x) * 0.3f;
    float smoothstepValue = smoothstep(0.0f, lerp(0.2f, 0.5f, breath_power), rawDistance);
    float gradient = 1.0f - smoothstepValue;
    
    return gradient * breath_power;
}

float3 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float mask = MaskGen(Tex0);
    
    float4 breath = s_breath.Sample(smp_rtlinear, Tex0);
    float3 color = s_image.Sample(smp_rtlinear, Tex0);
    float3 blur = s_image_blurred.Sample(smp_rtlinear, Tex0);
    
    breath.rgb *= breath.a * mask;
    color = lerp(color, blur, mask) + breath.rgb;
    
    return color;
}