#include "common.h"

cbuffer VolumetricLights
{
    float3 vMinBounds;
    float3 vMaxBounds;
    float4 FrustumClipPlane[6];
}

struct v2p
{
    float3 lightToPos : TEXCOORD0; // light center to plane vector
    float3 vPos : TEXCOORD1; // position in camera space
    float4 hpos : SV_Position;
};

v2p main(float3 P : POSITION)
{
    v2p o;
    float4 vPos;
    vPos.xyz = lerp(vMinBounds, vMaxBounds, P); //	Position in camera space
    vPos.w = 1;
    o.hpos = mul(m_P, vPos); // xform, input in camera coordinates

    o.lightToPos = vPos.xyz - Ldynamic_pos.xyz;
    o.vPos = vPos;

    return o;
}