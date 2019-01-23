#define snoise(p) (2 * (float noise(p)) - 1)

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
	
) {
	float vc = (v + 0.1) * 1.5;
	float uu = ( u - 0.5) / (1.0 - vc);
	float vv = (vc - 0.6) / (1.0 - vc);
	point pp = point(uu, vv, 0);

	float cloud = abs(fBm(pp + 98, 5, 2, 0.5));
	cloud *= smoothstep(0.55, 0.56, v);

	color c = mix((0.3, 0.3, 1.0), (1, 1, 1), cloud);

	Ci = c;
	Oi = Os;
} 

