#ifndef common_iostructs_h_included
#define common_iostructs_h_included

////////////////////////////////////////////////////////////////
//	This file contains io structs:
//	v_name	:	input for vertex shader.
//	v2p_name:	output for vertex shader.
//	p_name	:	input for pixel shader.
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//	TL
struct v_TL_positiont
{
    float4 P : POSITIONT;
    float2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
};

struct v_TL
{
    float4 P : POSITION;
    float2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
};

struct v2p_TL
{
    float2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
    float4 HPos : SV_Position;
};

struct v2p_TLD2
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float4 Color : COLOR0;
    float4 HPos : SV_Position;
};

struct v2p_TLD4
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Color : COLOR0;
    float4 HPos : SV_Position;
};

struct v2p_TL_FOG
{
    float2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

struct p_TL
{
    float2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
};

////////////////////////////////////////////////////////////////
//	Bloom

struct p_build
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float2 Tex3 : TEXCOORD3;
};

struct p_filter
{
    float4 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Tex2 : TEXCOORD2;
    float4 Tex3 : TEXCOORD3;
    float4 Tex4 : TEXCOORD4;
    float4 Tex5 : TEXCOORD5;
    float4 Tex6 : TEXCOORD6;
    float4 Tex7 : TEXCOORD7;
};

////////////////////////////////////////////////////////////////
//	Static
struct v_static
{
    float4 N : NORMAL;
    float4 T : TANGENT;
    float4 B : BINORMAL;
    int2 Tex0 : TEXCOORD0;
    float4 P : POSITION;
#ifdef USE_LM_HEMI
    int2 Tex1 : TEXCOORD1;
#endif
};

////////////////////////////////////////////////////////////////
//	defer
struct f_deffer
{
    float4 position : SV_Target0;
    float4 C : SV_Target1;
    float2 Velocity : SV_Target2;
    float4 H : SV_Target3;
};

struct gbuffer_data
{
    float3 P;
    float mtl;
    float3 N;
    float hemi;
    float3 C;
    float gloss;
};

////////////////////////////////////////////////////////////////
//	Defer bumped
struct v2p_bumped
{
    float2 tcdh : TEXCOORD0;
    float4 position : TEXCOORD1;
    float3 M1 : TEXCOORD2;
    float3 M2 : TEXCOORD3;
    float3 M3 : TEXCOORD4;
    float4 RDrops : TEXCOORD7;
#ifdef USE_TDETAIL
    float2 tcdbump : TEXCOORD5;
#endif
#ifdef USE_LM_HEMI
    float2 lmh : TEXCOORD6;
#endif
    float4 hpos_curr : TEXCOORD8;
    float4 hpos_old : TEXCOORD9;
    float4 hpos : SV_Position;
};

struct p_bumped
{
    float2 tcdh : TEXCOORD0;
    float4 position : TEXCOORD1;
    float3 M1 : TEXCOORD2;
    float3 M2 : TEXCOORD3;
    float3 M3 : TEXCOORD4;
    float4 RDrops : TEXCOORD7;
#ifdef USE_TDETAIL
    float2 tcdbump : TEXCOORD5;
#endif
#ifdef USE_LM_HEMI
    float2 lmh : TEXCOORD6;
#endif
    float4 hpos_curr : TEXCOORD8;
    float4 hpos_old : TEXCOORD9;
    float4 hpos : SV_Position;
};

////////////////////////////////////////////////////////////////
//	Defer flat
struct v2p_flat
{
    float2 tcdh : TEXCOORD0;
    float4 position : TEXCOORD1;
    float3 N : TEXCOORD2;
    float4 RDrops : TEXCOORD7;
#ifdef USE_TDETAIL
    float2 tcdbump : TEXCOORD3;
#endif
#ifdef USE_LM_HEMI
    float2 lmh : TEXCOORD4;
#endif
    float4 hpos_curr : TEXCOORD8;
    float4 hpos_old : TEXCOORD9;
    float4 hpos : SV_Position;
};

struct p_flat
{
    float2 tcdh : TEXCOORD0;
    float4 position : TEXCOORD1;
    float3 N : TEXCOORD2;
    float4 RDrops : TEXCOORD7;
#ifdef USE_TDETAIL
    float2 tcdbump : TEXCOORD3;
#endif
#ifdef USE_LM_HEMI
    float2 lmh : TEXCOORD4;
#endif
    float4 hpos_curr : TEXCOORD8;
    float4 hpos_old : TEXCOORD9;
};

////////////////////////////////////////////////////////////////
//	Shadow
struct v2p_shadow_direct
{
#ifdef USE_AREF
    float2 Tex0 : TEXCOORD0;
#endif
    float4 HPos : SV_Position;
};

////////////////////////////////////////////////////////////////
//	Model
struct v_model
{
    float4 P : POSITION;
    float3 N : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    float2 Tex0 : TEXCOORD0;
#ifndef SKIN_NONE
    float4 P_old : TEXCOORD1;
#endif
};

////////////////////////////////////////////////////////////////
//	Tree
struct v_tree
{
    float4 P : POSITION;
    float4 N : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    int4 Tex0 : TEXCOORD0;
    float4 M0 : COLOR0;
    float4 M1 : COLOR1;
    float4 M2 : COLOR2;
    float4 Consts : COLOR3;
};

////////for screenspace transformation
struct p_screen
{
    float2 Tex0 : TEXCOORD0;
    float4 HPos : SV_Position;
};

struct p_screen_volume
{
    float4 Tex0 : TEXCOORD0;
    float4 HPos : SV_Position;
};

struct v2p_screen
{
    float2 Tex0 : TEXCOORD0;
    float4 HPos : POSITIONT;
};
////////////////////////////////////////////////////////////////

#endif //	common_iostructs_h_included