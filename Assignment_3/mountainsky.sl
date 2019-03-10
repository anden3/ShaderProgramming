#define snoise(p) (2 * (float noise(p)) - 1)
#define ONE_MINUS(x) (1.0 - (x))

float fBm(
	point p;
	uniform float octaves, lacunarity, gain
) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += amp * snoise (pp);
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

surface mountainsky(
	uniform float skyFrequency = 1.0;

	uniform point skyOffset = point(100, 100, 100);

	uniform color COLOR_SKY 	= color(0.3, 0.3, 1.0);
	uniform color COLOR_CLOUD	= color(1.0, 1.0, 1.0);
) {
	// Change perspective of sky.
	float vc = ( v + 0.1) * 1.5;
	float uu = ( u - 0.5) / ONE_MINUS(vc);
	float vv = (vc - 0.6) / ONE_MINUS(vc);
	point pp = point(uu, vv, 0);

	// Generate clouds.
	float cloud = abs(
		fBm((pp + skyOffset) * skyFrequency, 5, 2, 0.5)
	);
	cloud *= smoothstep(0.55, 0.56, v);

    Ci = mix(COLOR_SKY, COLOR_CLOUD, cloud);
	Oi = Os;
} 

