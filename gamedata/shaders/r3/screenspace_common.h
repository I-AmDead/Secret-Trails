/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 11
 * @ Description: Main file
 * @ Modified time: 2022-09-25 07:58
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */


#include "common.h"
#include "hmodel.h"

#include "settings_screenspaceshaders.h"

#define SKY_EPS float(0.001)

static const float4 SSFX_ripples_timemul = float4(1.0f, 0.85f, 0.93f, 1.13f); 
static const float4 SSFX_ripples_timeadd = float4(0.0f, 0.2f, 0.45f, 0.7f);

uniform float4x4 m_inv_v;

uniform float4 rain_params; //x = raindensity

#if defined(USE_MSAA)
TEXTURE2DMS(float4, MSAA_SAMPLES) s_last_frame;
#else
Texture2D s_last_frame;
#endif

float3 calc_envmap(float3 vreflect)
{
	float3 vreflectabs = abs(vreflect);
	float  vreflectmax = max(vreflectabs.x, max(vreflectabs.y, vreflectabs.z));
	vreflect /= vreflectmax;
	if (vreflect.y < 0.999)
			vreflect.y= vreflect.y * 2 - 1; // fake remapping

	float3 env0 = env_s0.SampleLevel(smp_base, vreflect.xyz, 0).xyz;
	float3 env1 = env_s1.SampleLevel(smp_base, vreflect.xyz, 0).xyz;
	return lerp(env0, env1, L_ambient.w);
}

float SSFX_noise(float2 tc)
{
	float2 noise = frac(tc.xy * 0.5f);
	return noise.x + noise.y * 0.5f;
}

float2 SSFX_noise2(float2 p)
{
	p = p % 289;
	float x = (34 * p.x + 1) * p.x % 289 + p.y;
	x = (34 * x + 1) * x % 289;
	x = frac(x / 41) * 2 - 1;
	return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float SSFX_gradientNoise(float2 p)
{
	float2 ip = floor(p);
	float2 fp = frac(p);
	float d00 = dot(SSFX_noise2(ip), fp);
	float d01 = dot(SSFX_noise2(ip + float2(0, 1)), fp - float2(0, 1));
	float d10 = dot(SSFX_noise2(ip + float2(1, 0)), fp - float2(1, 0));
	float d11 = dot(SSFX_noise2(ip + float2(1, 1)), fp - float2(1, 1));
	fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
	return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

#define WATER_SPLASHES_MAX_RADIUS 1.5 // Maximum number of cells a ripple can cross.
//#define WATER_SPLASHES_DOUBLE_HASH	  // дополнительный шум

float hash12(float2 p)
{
	float3 p3 = frac(float3(p.xyx) * .1031);
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.x + p3.y) * p3.z);
}

float2 hash22(float2 p)
{
	float3 p3 = frac(float3(p.xyx) * float3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 19.19);
	return frac((p3.xx + p3.yz) * p3.zy);
}

float3 calc_rain_splashes(float2 tc)
{
	float2 p0 = floor(tc * 35);

	float circles = 0;

	for (int j = -WATER_SPLASHES_MAX_RADIUS; j <= WATER_SPLASHES_MAX_RADIUS; ++j)
	{
		for (int i = -WATER_SPLASHES_MAX_RADIUS; i <= WATER_SPLASHES_MAX_RADIUS; ++i)
		{
			float2 pi = p0 + float2(i, j);
		#ifdef WATER_SPLASHES_DOUBLE_HASH
			float2 hsh = hash22(pi);
		#else
			float2 hsh = pi;
		#endif
			float2 p = pi + hash22(hsh);

			float t = frac(1.45f * timers.x + hash12(hsh));
			float2 v = p - tc * 35;

			float d = (length(v) * 2.0f) - (float(WATER_SPLASHES_MAX_RADIUS) + 1.0) * t;

			const float h = 1e-3;
			float d1 = d - h;
			float d2 = d + h;
			float p1 = sin(31. * d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
			float p2 = sin(31. * d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
			circles += 0.5 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
		}
	}

	float c = float(WATER_SPLASHES_MAX_RADIUS * 2 + 1);
	circles /= c * c;

	return float3(circles.xx, sqrt(1.0f - dot(circles, circles)));
}

struct RayTrace
{
	float2 r_pos;
	float2 r_step;
	float2 r_start;
	float r_length;
	float z_start;
	float z_end;
};

bool SSFX_is_saturated(float2 value) { return (value.x == saturate(value.x) && value.y == saturate(value.y)); }

bool SSFX_is_valid_uv(float2 value) { return (value.x >= 0.0f && value.x <= 1.0f) && (value.y >= 0.0f && value.y <= 1.0f); }

float2 SSFX_view_to_uv(float3 Pos)
{
	float4 tc = mul(m_P, float4(Pos, 1));
	return (tc.xy / tc.w) * float2(0.5f, -0.5f) + 0.5f;
}

float SSFX_calc_SSR_fade(float2 tc, float start, float end)
{
	// Vectical fade
	float ray_fade = saturate(tc.y * 5.0f);
	
	// Horizontal fade
	float2 calc_edges = smoothstep(start, end, float2(tc.x, 1.0f - tc.x));
	ray_fade *= calc_edges.x * calc_edges.y;

	return ray_fade;
}

float3 SSFX_yaw_vector(float3 Vec, float Rot)
{
	float s = sin(Rot);
	float c = cos(Rot);
	
	// y-axis rotation matrix
	float3x3 rot_mat = 
	{
		c, 0, s,
		0, 1, 0,
		-s, 0, c
	};
	return mul(rot_mat, Vec);
}

float SSFX_get_depth(float2 tc, uint iSample : SV_SAMPLEINDEX)
{
	#ifndef USE_MSAA
		return s_position.Sample(smp_nofilter, tc).z;
	#else
		return s_position.Load(int3(tc * screen_res.xy, 0), iSample).z;
	#endif
}

float3 SSFX_get_position(float2 tc, uint iSample : SV_SAMPLEINDEX)
{
	#ifndef USE_MSAA
		return s_position.Sample(smp_nofilter, tc).xyz;
	#else
		return s_position.Load(int3(tc * screen_res.xy, 0), iSample).xyz;
	#endif
}

RayTrace SSFX_ray_init(float3 ray_start_vs, float3 ray_dir_vs, float ray_max_dist, int ray_steps, float noise)
{
	RayTrace rt;
	
	float3 ray_end_vs = ray_start_vs + ray_dir_vs * ray_max_dist;
	
	// Ray depth ( from start and end point )
	rt.z_start		= ray_start_vs.z;
	rt.z_end		= ray_end_vs.z;

	// Compute ray start and end (in UV space)
	rt.r_start		= SSFX_view_to_uv(ray_start_vs);
	float2 ray_end	= SSFX_view_to_uv(ray_end_vs);

	// Compute ray step
	float2 ray_diff	= ray_end - rt.r_start;
	rt.r_step		= ray_diff / (float)ray_steps; 
	rt.r_length		= length(ray_diff);
	
	rt.r_pos		= rt.r_start + rt.r_step * noise;
	
	return rt;
}

float3 SSFX_ray_intersect(RayTrace Ray, uint iSample)
{
	float len = length(Ray.r_pos - Ray.r_start);
	float alpha = len / Ray.r_length;
	float depth_ray = (Ray.z_start * Ray.z_end) / lerp(Ray.z_end, Ray.z_start, alpha);
	float depth_scene = SSFX_get_depth(Ray.r_pos, iSample);
	
	return float3(depth_ray.x - depth_scene, depth_scene, len);
}

// Half-way scene lighting
float4 SSFX_get_fast_scenelighting(float2 tc, uint iSample : SV_SAMPLEINDEX)
{
	#ifndef USE_MSAA
		float4 rL = s_accumulator.Sample(smp_nofilter, tc);
		float4 C = s_diffuse.Sample( smp_nofilter, tc );
	#else
		float4 rL = s_accumulator.Load(int3(tc * screen_res.xy, 0), iSample);
		float4 C = s_diffuse.Load(int3( tc * screen_res.xy, 0 ), iSample);
	#endif
	
	#ifdef SSFX_ENHANCED_SHADERS // We have Enhanced Shaders installed
		
		float3 hdiffuse = C.rgb + L_ambient.rgb;
		
		rL.rgb += rL.a * SRGBToLinear(C.rgb);
		
		return float4(LinearTosRGB((rL.rgb + hdiffuse) * saturate(rL.rrr * 100)), C.w);
		
	#else
		
		float3 hdiffuse = C.rgb + L_ambient.rgb;

		return float4((rL.rgb + hdiffuse) * saturate(rL.rrr * 100), C.w);
		
	#endif
}

// Full scene lighting
float3 SSFX_get_scene(float2 tc, uint iSample : SV_SAMPLEINDEX)
{
	#ifndef USE_MSAA
		float4 rP = s_position.Sample( smp_nofilter, tc );
	#else
		float4 rP = s_position.Load(int3(tc * screen_res.xy, 0), iSample);
	#endif

	if (rP.z <= 0.05f)
		return 0;

	#ifndef USE_MSAA
		float4 rD = s_diffuse.Sample( smp_nofilter, tc );
		float4 rL = s_accumulator.Sample(smp_nofilter, tc);
	#else
		float4 rD = s_diffuse.Load(int3(tc * screen_res.xy, 0), iSample);
		float4 rL = s_accumulator.Load(int3(tc * screen_res.xy, 0), iSample);
	#endif
	
	// Remove emissive materials for now...
	if (length(rL) > 10.0f)
		rL = 0;

	float3 rN = gbuf_unpack_normal( rP.xy );
	float rMtl = gbuf_unpack_mtl( rP.w );
	float rHemi = gbuf_unpack_hemi( rP.w );

	float3 nw = mul( m_inv_v, rN );

	// hemisphere
	float3 hdiffuse, hspecular;
	hmodel(hdiffuse, hspecular, rMtl, rHemi, rD.w, rP, rN);

	// Final color
	float4 light = float4(rL.rgb + hdiffuse, rL.w);
	float4 C = rD * light;
	float3 spec = C.www * rL.rgb;
	float3 color = C.rgb + spec;
	
    float fog = saturate(length(rP.xyz) * fog_params.w + fog_params.x);
    color = lerp(color, fog_color * TONEMAP_SCALE_FACTOR, fog);
	
	return color;
}

TextureCube sky_s0;
TextureCube sky_s1;

float3 SSFX_calc_sky(float3 vreflect)
{
	float3 a = abs(vreflect);
	vreflect.xyz /= max(a.x, max(a.y, a.z));

	if (vreflect.y < 0.999)
		vreflect.y = vreflect.y * 2 - 1;
	
	float3 env0 = sky_s0.SampleLevel(smp_base, vreflect, 0).xyz;
	float3 env1 = sky_s1.SampleLevel(smp_base, vreflect, 0).xyz;
	
	return lerp( env0, env1, env_color.w );
}