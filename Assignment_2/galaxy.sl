#define ARM_BRIGHTNESS 10
#define CENTER_BRIGHTNESS 1.5

#define INVERT(x) (1.0 - (x))

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
	uniform float colorMix    =  0.5;
	uniform float armCurve    =  3.0;
	uniform float starFreq    = 20.0;
	uniform float spiralFreq  =  5.0;
	uniform float spiralSpeed =  5.0;

	uniform color COLOR_GALAXY_A      = color(0.2, 0.2, 0.2);
	uniform color COLOR_GALAXY_B      = color(1.0, 1.0, 0.0);
	uniform color COLOR_GALAXY_CENTER = color(1.0, 1.0, 1.0);
) {
	// Change perspective of galaxy.
	float vc = (v - 0.1) * 1.5;
	float uu = ((u - 0.5) * 1.0) / INVERT(vc);
	float vv = (vc - 0.6) / INVERT(vc);

	// Get distance to center.
	float distc = length(point(uu, vv, 0));

	// Fade galaxy center based on distance.
	color galaxyCenter = COLOR_GALAXY_CENTER - smoothstep(0.1, 0.5, distc);

	// Make rays.
	float rays = INVERT(smoothstep(0.2, 0.7, abs(sin(
		(atan(vv, uu) + distc * armCurve) * spiralFreq
	))));

	// Make stars inside arms.
	point ppp = point(distc, atan(vv, uu) + distc * spiralSpeed, 0);
	float background = smoothstep(
		0.0, 0.3, INVERT(abs(fBm(ppp * starFreq, 6.0, 1.8, 0.5)))
	);

	// Combine arms and the stars inside them.
	float combined = rays * background * ARM_BRIGHTNESS;

	// Fade arms with distance.
	combined *= INVERT(smoothstep(0.1, 0.7, distc));

	vector galaxy = (combined, combined, combined);
	galaxy += galaxyCenter * CENTER_BRIGHTNESS;
	galaxy *= mix(COLOR_GALAXY_A, COLOR_GALAXY_B, colorMix);

	Ci = galaxy;
	Oi = Os * Ci;
} 

