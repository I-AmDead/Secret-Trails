//////////////////////////////////////////////////////////////////////////////////////////
// NV Shader by LVutner (basing on yaz NV)
// Last edit: 5:12 (22.05.19)
//////////////////////////////////////////////////////////////////////////////////////////

// defines
#define NV_BRIGHTNESS 5.0 // NV_COLOR.w

// effects
#define NV_FLICKERING
#define NV_NOISE
#define NV_VIGNETTE
#define NV_SCANLINES

// effect settings
#define FLICKERING_INTENSITY 0.0015
#define FLICKERING_FREQ 60.0
#define NOISE_INTENSITY 0.15 // NV_PARAMS.x
#define SCANLINES_INTENSITY 0.175 // NV_PARAMS.y
#define VIGNETTE_RADIUS 1.0

uniform float4 m_affects;
uniform float4 m_hud_params;

// https://stackoverflow.com/a/10625698
float random(float2 p)
{
    float2 K1 = float2(23.14069263277926f, // e^pi (Gelfond's constant)
                       2.665144142690225f // 2^sqrt(2) (Gelfondâ€“Schneider constant)
    );
    return frac(cos(dot(p, K1)) * 12345.6789f);
}

float get_noise(float2 co) { return (frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453)) * 0.5; }

float4 calc_night_vision_effect(float2 tc0, float4 color, float4 NV_COLOR, float4 NV_PARAMS)
{
    float lum = dot(color.rgb, float3(0.3f, 0.38f, 0.22f) * NV_COLOR.w); // instead of float3 use LUMINANCE_floatTOR in stalker
    color.rgb = NV_COLOR.xyz * lum;

    // cheap noise function
    float noise = get_noise(tc0 * timers.z) * m_affects.x * m_affects.x * 30;

    // glitch blowout
    float mig = 1.0f - (m_affects.x * 2.f);

//////////////////////////////////////////////////////////////////////////////////////////
// scanlines
#ifdef NV_SCANLINES
    color += NV_PARAMS.y * sin(tc0.y * screen_res.y * 2.0);
#endif
    //////////////////////////////////////////////////////////////////////////////////////////

    // узкая полоска искажений
    float problems = frac(timers.z * 5 * (1 + 2 * m_affects.x));
    tc0.x += (m_affects.x > 0.09 && tc0.y > problems - 0.01 && tc0.y < problems) ? sin((tc0.y - problems) * 5 * m_affects.y) : 0;

    // широкая полоска искажений
    problems = cos((frac(timers.z * 2) - 0.5) * 3.1416) * 2 - 0.8;
    float AMPL = 0.13;
    tc0.x -= (m_affects.x > 0.15 && tc0.y > problems - AMPL && tc0.y < problems + AMPL) ?
        cos(4.71 * (tc0.y - problems) / AMPL) * sin(frac(timers.z) * 6.2831 * 90) * 0.02 * (AMPL - abs(tc0.y - problems)) / AMPL :
        0;

    // тряска влево-вправо в финальной стадии
    tc0.x += (m_affects.x > 0.38) ? (m_affects.y - 0.5) * 0.04 : 0;

// noise
#ifdef NV_NOISE
    if (m_affects.y > 0)
        color += noise;
    else
        color += noise * NV_PARAMS.x;
#endif
//////////////////////////////////////////////////////////////////////////////////////////
// screen flickering
#ifdef NV_FLICKERING
    color += FLICKERING_INTENSITY * sin(timers.x * FLICKERING_FREQ);
#endif
//////////////////////////////////////////////////////////////////////////////////////////
// vignette
#ifdef NV_VIGNETTE
    color *= VIGNETTE_RADIUS - (distance(tc0.xy, float2(0.5f, 0.5f)));
    color *= smoothstep(0.55f, 0.4f, distance(tc0.xy, float2(0.5f, 0.5f)));
#endif

    // blowout device off
    color = random(timers.xz) > mig ? 0 : color;

    return color;
}