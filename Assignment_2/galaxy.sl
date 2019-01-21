float fBm(point p; uniform float octaves, lacunarity, gain) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += amp * noise(pp);
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

surface galaxy(
	float spiralFreq = 5.0;
	float spiralModulo = 3.14;
	float cloudFreq = 20;
) {
	// Change perspective of galaxy.
	float vc = (v - 0.1) * 1.5;
	float uu = ((u - 0.5) * 1.0) / (1.0 - vc);
	float vv = (vc - 0.6) / (1.0 - vc);

	point p1 = point(uu, vv, 0);
	point p2 = point(0, 0, 0);

	float distc = distance(p1, p2);

	color galaxyCenter = color(1.0, 1.0, 1.0) * 1.0 - smoothstep(0.1, 0.5, distc);

	point ppp = point(distc, atan(vv, uu) + distc * 5, 0);
	float background = smoothstep(0.0, 0.3, 1 - abs(fBm(ppp * cloudFreq, 6.0, 1.8, 0.5)));

	float rays = 1 - smoothstep(0.2, 0.7, abs(sin(
		(atan(vv, uu) + distc * 3) * spiralFreq
	)));

	float combined = rays * 10 * background;
	combined *= 1 - smoothstep(0.1, 0.7, distc);

	vector galaxy = (combined, combined, combined) + 1.5 * galaxyCenter;
	galaxy *= mix((0.2, 0.2, 0.2), (1.0, 1.0, 0.0), 0.5);

	Ci = galaxy;
	Oi = Os * Ci;
} 

