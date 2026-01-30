float3 Gauss_Horizontal(Texture2D t2d, float2 texCoord, float blur_factor)
{
    static const float weights[3] = {0.441, 0.279, 0.08};
    static const float offsets[3] = {0.0, 1.384, 3.230};
    
    float4 color = t2d.SampleLevel(smp_rtlinear, float3(texCoord, 0), 0) * weights[0];
    float pixelSize = blur_factor / screen_res.x;
    
    for (int i = 1; i < 3; i++)
    {
        float offset = offsets[i] * pixelSize;
        color += t2d.SampleLevel(smp_rtlinear, float3(texCoord + float2(offset, 0), 0), 0) * weights[i];
        color += t2d.SampleLevel(smp_rtlinear, float3(texCoord - float2(offset, 0), 0), 0) * weights[i];
    }
    
    return color;
}

float3 Gauss_Vertical(Texture2D t2d, float2 texCoord, float blur_factor)
{
    static const float weights[3] = {0.441, 0.279, 0.08};
    static const float offsets[3] = {0.0, 1.384, 3.230};
    
    float4 color = t2d.SampleLevel(smp_rtlinear, float3(texCoord, 0), 0) * weights[0];
    float pixelSize = blur_factor / screen_res.y;
    
    for (int i = 1; i < 3; i++)
    {
        float offset = offsets[i] * pixelSize;
        color += t2d.SampleLevel(smp_rtlinear, float3(texCoord + float2(0, offset), 0), 0) * weights[i];
        color += t2d.SampleLevel(smp_rtlinear, float3(texCoord - float2(0, offset), 0), 0) * weights[i];
    }
    
    return color;
}