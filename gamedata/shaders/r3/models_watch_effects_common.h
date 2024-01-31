uniform float4 game_time;

#define PI 3.14159265359
#define TPI 6.28318530718

#define timerX10 (timers.z * 10.0)

#define tt (timerX10 * 0.1)
#define ft (frac(tt))
#define it (floor(tt))

#define THICCNESS 0.01
#define RADIUS 0.15
#define SPEED 10.0

#define aa 2.0 / min(screen_res.x, screen_res.y)

float resize(float input, float factor, float offset) { return (input - 0.5f + offset) / factor + 0.5f - offset; }

float2x2 rotate(float r)
{
    float c = cos(r);
    float s = sin(r);
    return float2x2(c, -s, s, c);
}
float2 rotate(float2 p, float r) { return mul(rotate(r), p); }
float3 rotate(float3 p, float3 r)
{
    p.xy = rotate(p.xy, r.z);
    p.yz = rotate(p.yz, r.x);
    p.zx = rotate(p.zx, r.y);
    return p;
}

float3 hsv(float3 c)
{
    float3 rgb = c.x * 6. + float3(0.0, 4.0, 2.0);
    rgb = fmod(rgb, 6.0) - 3.0;
    rgb = abs(rgb) - 1.0;
    rgb = clamp(rgb, 0.0, 1.0);

    return mul(lerp(float3(1.0, 1.0, 1.0), rgb, c.y), c.z);
}

// returns 0 to 1 arc(turns of a circle) with 0 and 1 at the right
float hue(float2 p) { return frac(atan2(p.y, p.x) / TPI + 1.); }

float stepLinear(float a, float b, float t) { return clamp((t - a) / (b - a), 0., 1.); }

// originally https://www.shadertoy.com/view/ltl3DB
float easeSpring(float a, float b, float t)
{
    t = stepLinear(a, b, t);
    return 1.0 - cos(t * TPI * 3.0) * exp(-t * 12.5);
}

float easeInOutExpo(float t) { return (t == 0. || t == 1.) ? t : (t *= 2.) < 1. ? 0.5 * pow(2., 10. * (t - 1.)) : 0.5 * (-pow(2., -10. * (t - 1.)) + 2.); }

// iquilez - https://www.shadertoy.com/view/wl23RK
// sc is the sin/cos of the aperture
float sdArc(float2 p, float2 sc, float ra, float rb)
{
    p.x = abs(p.x);
    return ((sc.y > sc.x) ? length(p - sc * ra) : abs(length(p) - ra)) - rb;
}

float hash(float v) { return frac(sin(v) * 43758.5453); }
float hash(float2 v) { return frac(sin(dot(v, float2(12.9898, 78.233))) * 43758.5453); }
float noise_hash(float v)
{
    float f = frac(v), i = floor(v), u = f * f * (3.0 - 2.0 * f);
    return lerp(hash(i), hash(i + 1.0), u);
}
float noise_hash(float2 v)
{
    float2 f = frac(v), i = floor(v), u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(hash(i + float2(0.0, 0.0)), hash(i + float2(1.0, 0.0)), u.x), lerp(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), u.x), u.y);
}
float noise_hash(float3 v)
{
    float3 f = frac(v), i = floor(v), u = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 53.0 + i.z * 117.0;
    return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), u.x), lerp(hash(n + 53.0), hash(n + 54.0), u.x), u.y),
                lerp(lerp(hash(n + 117.0), hash(n + 118.0), u.x), lerp(hash(n + 170.0), hash(n + 171.0), u.x), u.y), u.z);
}
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0 * j);
    j *= 0.125;
    r.x = frac(512.0 * j);
    j *= 0.125;
    r.y = frac(512.0 * j);
    return r - 0.5;
}

float3 glitch(float3 p, float seed)
{
    float hs = hash(seed);
    float3 q = p;
    [unroll] for (int i = 0; i < 4; i++)
    {
        float fi = float(i) + 1.0;
        q = p * 2.0 * fi;
        float3 iq = floor(q);
        float3 fq = frac(q);
        float n = noise(rotate(iq, float3(hs, hs, hs)));
        float3 offset = 3.0 * random3(float3(n, n, n) * float3(10.486, 78.233, 65.912));
        if (hash(n) < 0.1)
        {
            p = p + offset;
            break;
        }
    }
    return p;
}
float3 glitch(float3 p) { return glitch(p, 43768.5453); }

float grid(float2 uv, float n, float w)
{
    uv = frac(uv * n);
    uv = abs(uv - 0.5);
    return 1.0 - smoothstep(-0.5 * w, 0.5 * w, min(uv.x, uv.y));
}

float box(float3 p, float3 b)
{
    float3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}
float box(float3 p, float b) { return box(p, float3(b, b, b)); }

float2 minD(float2 d1, float2 d2) { return d1.x < d2.x ? d1 : d2; }

float3 transform(float3 p)
{
    p = rotate(p, float3(0.25 * PI, 0.25 * PI, 0.0));
    return p;
}

#define IS_GLITCH (noise(timers.z * 12.0) < 0.6)

float2 map(float3 p)
{
    float2 d = float2(1e4, -1.0);

    float3 q1 = transform(p);
    float tn = 10.0 * hash(floor(timerX10 * 2.0) / 2.0);
    float qs = floor(timerX10 * tn) / tn;
    float3 q2 = glitch(q1, qs);

    float r = 0.5;
    float2 b = IS_GLITCH ? float2(box(q2, float3(r, r, r)), 2.0) : float2(box(q1, float3(r, r, r)), 1.0);
    d = minD(d, b);

    return d;
}

float2 trace(float3 ro, float3 rd, float2 tmm)
{
    float t = tmm.x;
    float m = -1.0;
    for (int i = 0; i < 200; i++)
    {
        float2 d = map(ro + rd * t);
        if (d.x < 1e-4 || tmm.y < t)
            break;
        t += d.x * 0.5;
        m = d.y;
    }
    if (tmm.y < t)
        m = -1.0;
    return float2(t, m);
}

float3 calcNormal(float3 p)
{
    float2 e = float2(1.0, -1.0) * 1.0 - 4.0;
    return normalize(e.xyy * map(p + e.xyy).x + e.yxy * map(p + e.yxy).x + e.yyx * map(p + e.yyx).x + e.xxx * map(p + e.xxx).x);
}

float3 render(float3 ro, float3 rd, float2 uv)
{
    float3 col = float3(0.0, 0.0, 0.0);
    float2 cmm = float2(0.0, 30.0);
    float2 res = trace(ro, rd, cmm);
    float t = res.x;
    float m = res.y;
    if (m < 0.0)
    {
        col = float3(0.0, 0.0, 0.0);
    }
    else
    {
        float3 pos = ro + rd * t;
        float3 nor = calcNormal(pos);
        float3 ref = reflect(rd, nor);
        float3 opos = transform(pos);

        float w = 0.2;
        float n = 5.0;
        float coll = grid(opos.xy + 0.5, n, w) + grid(opos.yz + 0.5, n, w);
        col = float3(coll, coll, coll);
        col = clamp(pow(col * 2.0, float3(1.4, 1.4, 1.4)), 0.0, 1.0);
        if (IS_GLITCH)
            col *= float3(3.0 * noise(floor(glitch(opos))), 0.0, 0.0);
    }
    return col;
}

float circle(float2 uv, float2 pos, float rad) { return 1.0 - smoothstep(rad, rad + 0.005, length(uv - pos)); }

float ring(float2 uv, float2 pos, float innerRad, float outerRad)
{
    return (1.0 - smoothstep(outerRad, outerRad + aa, length(uv - pos))) * smoothstep(innerRad - aa, innerRad, length(uv - pos));
}