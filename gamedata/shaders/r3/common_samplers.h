#ifndef	common_samplers_h_included
#define	common_samplers_h_included
sampler 	smp_nofilter;   //	Use D3DTADDRESS_CLAMP,	D3DTEXF_POINT,			D3DTEXF_NONE,	D3DTEXF_POINT 
sampler 	smp_rtlinear;	//	Use D3DTADDRESS_CLAMP,	D3DTEXF_LINEAR,			D3DTEXF_NONE,	D3DTEXF_LINEAR 
sampler 	smp_linear;		//	Use	D3DTADDRESS_WRAP,	D3DTEXF_LINEAR,			D3DTEXF_LINEAR,	D3DTEXF_LINEAR
sampler 	smp_base;		//	Use D3DTADDRESS_WRAP,	D3DTEXF_ANISOTROPIC, 	D3DTEXF_LINEAR,	D3DTEXF_ANISOTROPIC

Texture2D 	s_base;

#ifdef USE_MSAA
Texture2DMS<float4, MSAA_SAMPLES>	s_generic;
#else
Texture2D   s_generic;
#endif

Texture2D 	s_bump;
Texture2D 	s_bumpX;
Texture2D 	s_detail;
Texture2D 	s_detailBump;
Texture2D 	s_detailBumpX;

Texture2D 	s_hemi;
Texture2D	s_brdf;

Texture2D 	s_mask;

Texture2D 	s_dt_r;
Texture2D 	s_dt_g;
Texture2D 	s_dt_b;
Texture2D 	s_dt_a;

Texture2D 	s_dn_r;
Texture2D 	s_dn_g;
Texture2D 	s_dn_b;
Texture2D 	s_dn_a;

//////////////////////////////////////////////////////////////////////////////////////////
// Lighting/shadowing phase
//////////////////////////////////////////////////////////////////////////////////////////
sampler 	smp_material;

#ifdef USE_MSAA
Texture2DMS<float4, MSAA_SAMPLES>	s_position;
Texture2DMS<float4, MSAA_SAMPLES>	s_normal;
#else
Texture2D	s_position;
Texture2D	s_normal;
#endif

Texture2D	s_lmap;
Texture3D	s_material;
Texture2D	s_mat_data;

//////////////////////////////////////////////////////////////////////////////////////////
// Combine phase
//////////////////////////////////////////////////////////////////////////////////////////
#ifdef USE_MSAA
Texture2DMS<float4, MSAA_SAMPLES>	s_diffuse;
Texture2DMS<float4, MSAA_SAMPLES>	s_accumulator;
#else
Texture2D	s_diffuse;
Texture2D	s_accumulator;
#endif

//Other
Texture2D s_blur_2;
Texture2D s_blur_4;
Texture2D s_blur_8;

Texture2D	s_bloom;
Texture2D	s_image;
Texture2D	s_tonemap;

#endif