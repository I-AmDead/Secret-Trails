#include "models_watch_effects_common.h"

// https://www.shadertoy.com/view/styBzt
float3 watch_loading(float2 uv)
{
    uv -= 0.5;

    float3 color = float3(0.0, 0.0, 0.0);

    float d = abs(length(uv) - 0.25) - 0.025;
    float3 rainbow = hsv(float3(hue(uv), 1.0, 1.0));

    float t = fmod((timerX10) * 0.9, 3.0);

    float phaseOffset = 3.0 * TPI / 8.0;
    float a = atan2(uv.y, uv.x);
    a /= TPI;
    a += 1.0;
    a = frac(a);
    a = clamp(a, 0.0, 1.0);
    a += 1.0 / 8.0;
    float aRepeat = floor(a * 4.0);
    uv = rotate(uv, aRepeat * TPI / 4.0);

    float h = hue(uv);

    float r = 0.25 * (easeSpring(0.0, 1.0, t) - easeSpring(2.0, 3.0, t));
    float radius = 0.045;
    float tSweep = easeInOutExpo(stepLinear(1.0, 2.0, t));
    float aDot = tSweep * TPI / 4.0 - TPI / 8.0;
    float innerD = 1.0;
    for (float i = 0.0; i <= 3.0; i++)
    {
        float2 pDot2 = rotate(uv, aDot + TPI / 4.0 * i);
        float arcLength = TPI / 16.0 * tSweep;
        float arc = sdArc(pDot2, float2(sin(arcLength), cos(arcLength)), r, radius);
        innerD = min(innerD, arc);
    }

    float hueMix = 1.0 - abs((r / 0.25) - 1.0);
    float dCut = smoothstep(screen_res.z, -screen_res.z, innerD);
    color = lerp(color, float3(1.0, 1.0, 1.0), dCut);
    color = lerp(color, color * rainbow, hueMix);

    return color;
}

// https://www.shadertoy.com/view/3dVXzh
float3 glitch_cube(float2 uv)
{
    uv.x = resize(uv.x, screen_res.x / screen_res.y, 0.0);

    float2 p = uv;
    p -= 0.5;
    p.x *= screen_res.x * screen_res.w;
    p *= 2.0;

    float3 col = float3(0.0, 0.0, 0.0);

    float3 ro = float3(0.0, -0.2 * ft, 4.0 - 2.0 * ft);
    if (hash(frac(it * 432.543)) < 0.5)
    {
        ro.x += hash(it * 12.9898) * 2.0 - 1.0;
        ro.y += hash(it * 78.233) * 2.0 - 1.0;
    }

    float3 ta = float3(0.0, 0.0, 0.0);

    float cr = 0.0;
    float3 cz = normalize(ta - ro);
    float3 cx = normalize(cross(cz, float3(sin(cr), cos(cr), 0.0)));
    float3 cy = normalize(cross(cx, cz));
    float3 rd = normalize(mul(float3x3(cx, cy, cz), float3(p, 2.0)));

    col = render(ro, rd, rd.xy);
    col *= smoothstep(0.0, 0.2, 1.0 - abs(ft * 2.0 - 1.0));

    return col;
}

// https://www.shadertoy.com/view/Xd3cR8
float3 pda_loading(float2 uv)
{
    uv.x = resize(uv.x, 0.6, 0.0);
    uv -= 0.5;
    uv.x = -uv.x;

    float geo = ring(uv, float2(0.0, 0.0), RADIUS - THICCNESS, RADIUS);

    float rot = timers.z * SPEED;

    uv = mul(uv, float2x2(cos(rot), sin(rot), -sin(rot), cos(rot)));

    float a = atan2(uv.x, uv.y) * PI * 0.05 + 0.5;

    a = max(a, circle(uv, float2(0.0, -RADIUS + THICCNESS / 2.0), THICCNESS / 2.0));

    return a * geo;
}

float3 dosimeter(float2 uva)
{
    float2 uv = uva;

    // uv -= 0.5;
    // uv.y = -uv.y;

    uv *= 280.0;
    float deg = radiansToDegrees(atan2(uv.y, uv.x));

    float4 rgba = float4(0.0, 0.0, 0.0, 1.0);

    if (uv.y > 0.0 && length(uv) < 190.0 && length(uv) > 170.0)
    {
        float4 red = float4(1.0, 0.0, 0.0, 1.0);
        float4 yellow = float4(1.0, 1.0, 0.0, 1.0);
        float4 green = float4(0.0, 1.0, 0.0, 1.0);

        if (deg < 90.0)
            rgba = lerp(red, yellow, deg / 90.0);
        else
            rgba = lerp(yellow, green, (deg - 90.0) / 90.0);

        if (fmod(deg, 12.0) < 2.0 && (length(uv) > 175.0 || length(uv) <= 175.0))
            rgba = float4(0.0, 0.0, 0.0, 1.0);
    }

    float rad_level = radiation_effect.z;
    rad_level = clamp(rad_level, 0.0, 1.0);
    uv = mul(uv, rotate(-abs(sin(1.4) * rad_level) * PI));

    if (uv.x < 0.0 && abs((uv.x + 180.0) / 50.0) > abs(uv.y) && uv.x > -160.0 || length(uv) < 6.0)
        rgba = float4(0.5, 0.4, 0.1, 1.0);

    return rgba.rgb;
}

float3 NixieTime(float2 uv)
{
    uv.x = resize(uv.x, screen_res.x / screen_res.y, 0.0);

    float2 uva = uv;
    // uva.y -= 0.2;

    uv -= 0.5;
    uv *= 1.1;
    uv.x *= screen_res.x * screen_res.w;
    uv.y = -uv.y;

    float hour = game_time.x;
    float minute = game_time.y;
    float seconds = game_time.z;
    float miliseconds = game_time.w;
    float radiation = round(watch_actor_params_1.z);

    float nsize = numberLength(9999.0);
    float2 digit_spacing = mul(float2(1.1, 1.6), 1.0 / 6.0);
    float2 pos = -digit_spacing * float2(nsize, 1.0) / 2.0;

    float2 basepos = pos;
    float dist = 1.0;

    float3 color = float3(0.0, 0.0, 0.0);

    float3 red_color = float3(0.9, 0.1, 0.0);
    float3 green_color = float3(0.0, 0.9, 0.1);
    float3 blue_color = float3(0.0, 0.1, 0.7);

    if (watch_actor_params_1.w == 1)
    {
        pos.x = basepos.x + 0.16;
        dist = min(dist, dfNumber(pos, hour, uv));

        pos.x = basepos.x + 0.39;
        dist = min(dist, dfColon(pos, uv));

        pos.x = basepos.x + 0.60;
        dist = min(dist, dfNumber(pos, minute, uv));
    }

    if (watch_actor_params_1.w == 2)
    {
        bool indicators_show =
            watch_actor_params_2.x < 0.99 || watch_actor_params_2.y < 0.99 || watch_actor_params_2.z < 1.0 || watch_actor_params_2.w < 0.99 || watch_actor_params_1.y < 0.99;

        int health_factor = round(watch_actor_params_1.x * 100);
        pos.x -= 0.2;
        pos.y += indicators_show ? 0.1 : 0.0;
        pos.x = basepos.x + (health_factor < 100.f ? (health_factor < 10.f ? 0.42 : 0.33) : 0.22);
        dist = min(dist, dfNumberHealth(pos, health_factor, uv));

        pos.x += health_factor < 100.f ? (health_factor < 10.f ? 0.2 : 0.35) : 0.55;
        dist = min(dist, dfPercent(pos, uv));

        pos.y -= 0.35;
        pos.x = basepos.x + 0.15;

        // Icons
        if (watch_actor_params_2.x < 0.99)
        {
            float eatDist = dfEat(pos, uv);
            if (watch_actor_params_2.x < 0.0)
                color += lerp(blue_color, color, watch_actor_params_2.x) * (0.001 / eatDist);
            else
                color += lerp(red_color, green_color, watch_actor_params_2.x) * (0.001 / eatDist);
        }

        pos.x += 0.25;

        if (watch_actor_params_2.y < 0.99)
        {
            float radioDist = dfRadio(pos, uv);
            if (watch_actor_params_2.y < 0.0)
                color += lerp(blue_color, color, watch_actor_params_2.y) * (0.001 / radioDist);
            else
                color += lerp(red_color, green_color, watch_actor_params_2.y) * (0.001 / radioDist);
        }

        pos.x += 0.25;

        if (watch_actor_params_2.z < 1.0)
        {
            float kettlebellDist = dfKettlebell(pos, uv);
            if (watch_actor_params_2.z < 0.0)
                color += lerp(blue_color, color, watch_actor_params_2.z) * (0.001 / kettlebellDist);
            else
                color += lerp(red_color, green_color, watch_actor_params_2.z) * (0.001 / kettlebellDist);
        }

        pos.x += 0.25;

        if (watch_actor_params_2.w < 0.99)
        {
            float dropDist = dfDrop(pos, uv);
            if (watch_actor_params_2.w < 0.0)
                color += lerp(blue_color, color, watch_actor_params_2.w) * (0.001 / dropDist);
            else
                color += lerp(red_color, green_color, watch_actor_params_2.w) * (0.001 / dropDist);
        }

        pos.x += 0.15;

        if (watch_actor_params_1.y < 0.99)
        {
            float radDist = dfRadiation(pos, uv);
            if (watch_actor_params_1.y < 0.0)
                color += lerp(blue_color, color, watch_actor_params_1.y) * (0.001 / radDist);
            else
                color += lerp(red_color, green_color, watch_actor_params_1.y) * (0.001 / radDist);
        }
    }

    if (watch_actor_params_1.w == 3)
    {
        uv *= 1.3;
        pos = basepos;
        pos.x += 0.15;
        pos.y -= 0.3;
        dist = min(dist, dfNumber2(pos, radiation, uv));

        color += dosimeter(uv);
    }

    if (watch_actor_params_1.w == 4)
    {
        uv *= 1.5;

        pos.x = basepos.x - 0.15;
        dist = min(dist, dfNumber(pos, minute, uv));

        pos.x = basepos.x + 0.1;
        dist = min(dist, dfColon(pos, uv));

        pos.x = basepos.x + 0.35;
        dist = min(dist, dfNumber(pos, seconds, uv));

        pos.x = basepos.x + 1.75;
        pos.y = basepos.y - 0.75;
        dist = min(dist, dfCircle(pos, 0.04, uv));

        pos.x = basepos.x + 0.8;
        pos.y = basepos.y;
        dist = min(dist, dfNumber(pos, miliseconds, uv));
    }

    float shade = 0.004 / dist;
    color += watch_color_params.rgb * shade;

#ifdef SHOW_GRID
    float grid = 0.5 - max(abs(fmod(uva.x * 64.0, 1.0) - 0.3), abs(fmod(uva.y * 64.0, 1.0) - 0.3));
    float mixing = smoothstep(0.0, 64.0 / screen_res.y, grid);
    color *= 0.25 + float3(mixing, mixing, mixing);
#endif

    return color;
}