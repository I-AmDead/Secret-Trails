#include "models_watch_effects_common.h"

float3 watch_seconds(float2 uv)
{
    // Изменение размера текстурных координат
    uv.x = resize(uv.x, screen_res.x / screen_res.y, 0.0);

    // Коррекция текстурных координат и преобразование их в координаты экрана
    float2 p = uv;
    p -= 0.5;
    p.x *= screen_res.x * screen_res.w;

    // Получение текущего времени игры
    float time = game_time.z;

    // Расчет угла поворота на основе времени
    float angle = (time * 1.0 / 60.0) * 2.0 * PI;

    // Создание матрицы поворота 2x2
    float2x2 rot = float2x2(cos(angle), sin(angle), -sin(angle), cos(angle));

    // Применение поворота к текстурным координатам и масштабирование на 0.73
    p = mul(rot, p) * 0.73;

    // Установка базового цвета в черный
    float3 color_base = float3(0.0, 0.0, 0.0);

    // Расчет расстояния от центра экрана
    float L = length(p);

    // Инициализация переменной для наложения
    float f = 0.;

    // Использование smoothstep для создания плавного перехода в наложении
    f = smoothstep(L - 0.005, L, 0.35);
    f -= smoothstep(L, L + 0.005, 0.33);

    // Коррекция времени для анимации и установка пороговых углов
    float t = fmod(time, TPI) - PI;
    float t1 = -PI;
    float t2 = PI;
    float t3 = PI - 6.1;

    // Расчет угла на основе текстурных координат
    float a = atan2(p.x, p.y);

    // Наложение на основе угла и порогов
    float f_final = f * step(a, t3);
    f = f * step(a, t2);

    // Использование линейной интерполяции для смешивания цветов на основе расчетных факторов
    float3 col2 = lerp(color_base, float3(0.21, 0.21, 0.21), f);
    float3 col3 = lerp(color_base, float3(cos(timers.x), cos(timers.x + TPI / 3.0), cos(timers.x + 2.0 * TPI / 3.0)), f_final);

    // Установка значений альфа для выходных цветов
    float4 fragColor1 = float4(col2, 0.0);
    float4 fragColor2 = float4(col3, 0.0);

    // Применение дополнительной прозрачности на основе интенсивности цвета
    if (fragColor1.r > 0.2 || fragColor1.g > 0.2 || fragColor1.b > 0.2)
        fragColor1.a = 0.5;

    if (fragColor2.r > 0.3 || fragColor2.g > 0.3 || fragColor2.b > 0.3)
        fragColor2.a = 0.8;

    return fragColor1 + fragColor2;
}

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
    // Изменение размера текстурных координат
    uv.x = resize(uv.x, screen_res.x / screen_res.y, 0.0);

    // Коррекция текстурных координат и преобразование их в координаты экрана
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
    // Изменение размера текстурных координат
    uv.x = resize(uv.x, 0.6, 0.0); // Тут отмасштабировал под наш ui
    uv -= 0.5;
    uv.x = -uv.x; 

    float geo = ring(uv, float2(0.0, 0.0), RADIUS - THICCNESS, RADIUS);

    float rot = timers.z * SPEED; // На GL -timers.z

    uv = mul(uv, float2x2(cos(rot), sin(rot), -sin(rot), cos(rot)));

    float a = atan2(uv.x, uv.y) * PI * 0.05 + 0.5;

    a = max(a, circle(uv, float2(0.0, -RADIUS + THICCNESS / 2.0), THICCNESS / 2.0));

    return a * geo;
}