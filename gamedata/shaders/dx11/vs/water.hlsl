#include "common\common.h"
#include "common\shared\waterconfig.h"
#include "common\shared\watermove.h"

struct VSInput
{
    float4 P : POSITION;
    float4 N : NORMAL;
    float4 T : TANGENT;
    float4 B : BINORMAL;
    float4 Color : COLOR0;
    int2 Tex0 : TEXCOORD0;
};

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float3 Tex2 : TEXCOORD2;
    float3 Tex3 : TEXCOORD3;
    float3 Tex4 : TEXCOORD4;
    float3 Tex5 : TEXCOORD5;
    float3 Tex6 : TEXCOORD6;
    float4 Tex7 : TEXCOORD7;
    float4 Color : COLOR0;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

uniform float4x4 m_texgen;

VSOutput main(VSInput I)
{
    I.N = unpack_D3DCOLOR(I.N);
    I.T = unpack_D3DCOLOR(I.T);
    I.B = unpack_D3DCOLOR(I.B);
    I.Color = unpack_D3DCOLOR(I.Color);

    VSOutput O;

    float4 P = I.P; // world
    O.Tex2 = P.xyz;

    P = watermove(P);

    O.Tex6 = P - eye_position;
    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w); // copy tc
    O.Tex1.xy = watermove_tc(O.Tex0 * W_DISTORT_BASE_TILE_0, P.xz, W_DISTORT_AMP_0);
    O.Tex1.zw = watermove_tc(O.Tex0 * W_DISTORT_BASE_TILE_1, P.xz, W_DISTORT_AMP_1);

    // Calculate the 3x3 transform from tangent space to eye-space
    float3 N = unpack_bx2(I.N); // just scale (assume normal in the -.5f, .5f)
    float3 T = unpack_bx2(I.T); //
    float3 B = unpack_bx2(I.B); //
    float3x3 xform = mul((float3x3)m_W, float3x3(T.x, B.x, N.x, T.y, B.y, N.y, T.z, B.z, N.z));

    // Feed this transform to pixel shader
    O.Tex3 = xform[0];
    O.Tex4 = xform[1];
    O.Tex5 = xform[2];

    float3 L_rgb = I.Color.xyz; // precalculated RGB lighting
    float3 L_hemi = v_hemi(N) * I.N.w; // hemisphere
    float3 L_sun = v_sun(N) * I.Color.w; // sun
    float3 L_final = L_rgb + L_hemi + L_sun + L_ambient;

    O.HPos = mul(m_VP, P); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);
    O.Fog = saturate(calc_fogging(I.P));

    O.Color = float4(L_final, 1);

    // Igor: for additional depth dest
    O.Tex7 = mul(m_texgen, P);
    float3 Pe = mul(m_V, P);
    O.Tex7.z = Pe.z;

    return O;
}