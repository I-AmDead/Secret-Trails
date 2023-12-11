#ifndef MBLUR_H
#define MBLUR_H

#ifndef USE_MBLUR
float3 mblur (float2 UV, float3 pos, float3 c_original, uint iSample = 0) { return c_original; }
#else // USE_MBLUR

#include "mblur_settings.h"

#include "common.h"
////////////////////////////////////////
float4x4 m_current;   //Current projection matrix
float4x4 m_previous;  //Previous projection matrix
float2   m_blur;
////////////////////////////////////////

// https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences
float emblur_r1(float n) {
    static const float g = 1.6180339887498948482;
    static const float a1 = 1.0 - 1.0/g;
    const float _n = floor(n);
    return frac(0.5 + a1*_n);
}

float2 emblur_r2(float n) {
    static const float g = 1.32471795724474602596;
    static const float a1 = 1.0 - 1.0/g;
    static const float a2 = 1.0 - 1.0/(g*g);
    const float _n = floor(n);
    return float2(frac(0.5+a1*_n), frac(0.5+a2*_n));
}

float3 emblur_r3(float n) {
    static const float g = 1.22074408460575947536;
    static const float a1 = 1.0 - 1.0/g;
    static const float a2 = 1.0 - 1.0/(g*g);
    static const float a3 = 1.0 - 1.0/(g*g*g);
    const float _n = floor(n);
    return float3(frac(0.5+a1*_n), frac(0.5+a2*_n), frac(0.5+a3*_n));
}

float emblur_I(float2 tc) {
    return frac(52.9829189 * frac(0.06711056*tc.x + 0.00583715*tc.y));
}

// Functions were taken from Screen Space Shaders and were modified by me
float4 emblur_get_position(float2 tc, uint iSample : SV_SAMPLEINDEX) {
#ifndef USE_MSAA
    return s_position.Sample(smp_nofilter, tc);
#else
    return s_position.Load(int3(tc * screen_res.xy, 0), iSample);
#endif // USE_MSAA
}

float3 emblur_get_image(float2 tc, uint iSample : SV_SAMPLEINDEX) {
    return s_image.Load(int3(tc * screen_res.xy, 0)).rgb;
}

float3 emblur_get_image_offset(float2 tc, uint iSample : SV_SAMPLEINDEX, int2 offset) {
    return s_image.Load(int3(tc * screen_res.xy, 0), offset).rgb;
}

float emblur_min3(float3 v) {
    return min(v.x, min(v.y, v.z));
}

float emblur_max3(float3 v) {
    return max(v.x, max(v.y, v.z));
}

// https://changingminds.org/explanations/perception/visual/colourfulness.htm
float emblur_colorfulness(float3 c) {
    const float mi = emblur_min3(c);
    const float ma = emblur_max3(c);
    return ((ma + mi) * (ma - mi))/ma;
}

float emblur_sight_mask(float2 tc, float3 img, uint iSample) {
    const float2 aspect = float2(screen_res.x/screen_res.y, 1.);
    const float len = saturate(EMBLUR_SIGHT_MASK_SIZE - length((tc - 0.5)*aspect)*75.);

    float mask = 0.0;

#ifdef EMBLUR_SIGHT_MASK_COLOR
    #define EMBLUR_SM_SAMPLE(color) mask += saturate((emblur_colorfulness(color) - EMBLUR_SIGHT_MASK_COLOR_THRESHOLD) * EMBLUR_SIGHT_MASK_COLOR_CONTRAST);
        EMBLUR_SM_SAMPLE(img)
        #if EMBLUR_SIGHT_MASK_COLOR_EXTRA_SAMPLES >= 4
            EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2(-1, -1)))
            EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2( 1, -1)))
            EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2(-1,  1)))
            EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2( 1,  1)))

            #if EMBLUR_SIGHT_MASK_COLOR_EXTRA_SAMPLES >= 8
                EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2(-2, -2)))
                EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2( 2, -2)))
                EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2(-2,  2)))
                EMBLUR_SM_SAMPLE(mblur_get_image_offset(tc, iSample, int2( 2,  2)))
            #endif // EMBLUR_SIGHT_MASK_COLOR_EXTRA_SAMPLES >= 8
        #endif // EMBLUR_SIGHT_MASK_COLOR_EXTRA_SAMPLES >= 4
    #undef EMBLUR_SM_SAMPLE

    return 1.0 - saturate(mask) * len;
#else  // EMBLUR_SIGHT_MASK_COLOR
    return 1.0 - len;
#endif // EMBLUR_SIGHT_MASK_COLOR
}

float emblur_weapon_mask(float3 pos) {
    return saturate((length(pos) - EMBLUR_WPN_RADIUS) / EMBLUR_WPN_RADIUS_SMOOTHING);
}

float3 mblur(float2 UV, float3 pos, float3 img, uint iSample = 0)
{
    //Fix sky ghosting caused by infinite depth value (KD)
    pos.z += (saturate(0.001 - pos.z)*10000.h);

    //Sample position buffer
    float4 pos4 = float4(pos, 1.0);

    //Get current texture coordinates
    float4 p_current = mul(m_current, pos4);
    float2 current_tc = p_current.xy /= p_current.w;

    //Get previous texture coordinates
    float4 p_previous = mul(m_previous, pos4);
    float2 previous_tc = p_previous.xy / p_previous.w;

    //Get velocity (multiplied with motion blur intensity)
    float2 p_velocity = (current_tc - previous_tc) * m_blur * EMBLUR_LENGTH;
    p_velocity = clamp(p_velocity,-EMBLUR_CLAMP,+EMBLUR_CLAMP);

#ifdef EMBLUR_WPN
    //Small hud attenuation
    p_velocity *= emblur_weapon_mask(pos);
#endif // EMBLUR_WPN

#ifdef EMBLUR_SIGHT_MASK
    //Apply sight mask on velocity
    p_velocity *= emblur_sight_mask(UV, img, iSample);
#endif // EMBLUR_SIGHT_MASK

    //Accumulate motion blur samples
    float3 accum = img;
    float occ = 1.0;

    //gimme ze blur
    [unroll (EMBLUR_SAMPLES)]
    for (int i = 1; i <= EMBLUR_SAMPLES; i++) {
        const float ID = float(i) + emblur_I(UV*screen_res.xy)*1024.0;
#ifdef EMBLUR_CONE_DITHER
        const float2 noise2 = emblur_r2(ID) * 2.0 - 1.0;
#endif // EMBLUR_CONE_DITHER
        const float noise1 = emblur_r1(ID) * 2.0 - 1.0;
        const float dither = (1 - noise1 * EMBLUR_DITHER / float(i));
        
        float2 offset;

#ifdef EMBLUR_DUAL
        if (i <= EMBLUR_SAMPLES / 2) {
            offset = p_velocity * float(i);
        } else {
            offset = p_velocity * float(-i + EMBLUR_SAMPLES / 2);
        }
#else
        offset = p_velocity * float(i);
#endif // EMBLUR_DUAL

#ifdef EMBLUR_CONE_DITHER
        offset += length(offset) * noise2 * EMBLUR_CONE_DITHER;
#endif // EMBLUR_CONE_DITHER
        
        offset = offset / EMBLUR_SAMPLES * dither;

        float amount = 1.0;
        // clamped to 0.0-0.999999 becase for some reason clamping to 0.0-1.0 doesn't work
        float2 tc = clamp(UV + offset, 0.0, 0.999999);

        float3 simg = emblur_get_image(tc, iSample).rgb;

#ifdef EMBLUR_WPN
        float3 spos = emblur_get_position(tc, iSample).xyz;
        
        //Fix sky ghosting caused by infinite depth value (KD)
        spos.z += (saturate(0.001 - spos.z)*10000.h);
        
        amount = emblur_weapon_mask(spos);
#endif // EMBLUR_WPN

#ifdef EMBLUR_SIGHT_MASK
        amount *= emblur_sight_mask(tc, simg, iSample);
#endif // EMBLUR_SIGHT_MASK

        accum += simg * amount;

        occ += amount;
    }

    accum /= occ;

    return accum;
}
#endif // USE_MBLUR
#endif // MBLUR_H
