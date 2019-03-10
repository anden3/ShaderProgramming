#define TRANSITION_BEACH 1
#define TRANSITION_OCEAN 3

#define UP vector(0, 1, 0)

#define snoise(p) (2 * (float noise(p)) - 1)
#define ONE_MINUS(x) (1.0 - (x))

float RidgedMultifractal(
	point p;
	uniform float octaves, lacunarity, gain, H, sharpness, threshold
) {
	float result, signal, weight, i, exponent;
	varying point PP = p;

	for (i = 0; i < octaves; i += 1) {
       	if (i == 0) {
			signal = pow(gain - abs(snoise(PP)), sharpness);
			result = signal;
          	weight = 1.0;
        }
		else {
			exponent = pow(lacunarity, (-i * H));
			PP *= lacunarity;

			weight = clamp(signal * threshold, 0, 1);
			signal = pow(gain - abs(snoise(PP)), sharpness) * weight;

          	result += signal * exponent;
       	}
	}

	return(result);
}

void voronoi_f1f2_2d(
	float ss, tt;

	output float f1;
	output float spos1, tpos1;
	output float f2;
	output float spos2, tpos2;
) {
	float jitter = 1.0;

	float sthiscell = floor(ss) + 0.5;
	float tthiscell = floor(tt) + 0.5;

	f1 = f2 = 1000;
	uniform float i, j;

	for (i = -1; i <= 1; i += 1) {
		float stestcell = sthiscell + i;

		for (j = -1; j <= 1; j += 1) {
			float ttestcell = tthiscell + j;

			float spos = stestcell + jitter * (cellnoise(stestcell, ttestcell) - 0.5);
			float tpos = ttestcell + jitter * (cellnoise(stestcell+23, ttestcell-87) - 0.5);

			float soffset = spos - ss;
			float toffset = tpos - tt;

			float dist = soffset*soffset + toffset*toffset;
			
			if (dist < f1) { 
				f2 = f1;
				spos2 = spos1;
				tpos2 = tpos1;

				f1 = dist;
				spos1 = spos;
				tpos1 = tpos;
			}
			else if (dist < f2) {
				f2 = dist;
				spos2 = spos;
				tpos2 = tpos;
			}
		}
	}

  	f1 = sqrt(f1);
	f2 = sqrt(f2);
}

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

float turbulence(
	point p;
	uniform float octaves, lacunarity, gain
) {
	uniform float amp = 1;
	varying point pp = p;
	varying float sum = 0;

	uniform float i;
  
	for (i = 0; i < octaves; i += 1) {
		sum += abs(amp * snoise (pp));
		amp *= gain;
		pp *= lacunarity;
	}

	return sum;
}

surface mountain(
	uniform float seaLevel          = 20;
	uniform float waveHeight        = 1.0;
	uniform float fogIntensity      = 1.0;
	uniform float waveFrequency     = 0.05;
	uniform float forestFrequency   = 0.05;
	uniform float terrainFrequency  = 0.003;
	uniform float terrainHeightCoef = 120;

	uniform point terrainOffset = point(100, 100, 100);

	uniform color COLOR_FOG    = color(1.0, 1.0, 1.0);
	uniform color COLOR_LAND   = color(0.0, 0.8, 0.3);
	uniform color COLOR_FOREST = color(0.0, 0.3, 0.0);
	uniform color COLOR_CLIFFS = color(0.6, 0.6, 0.6);
	uniform color COLOR_BEACH  = color(1.0, 0.9, 0.8);
	uniform color COLOR_OCEAN  = color(0.0, 0.0, 1.0);
	uniform color COLOR_WAVES  = color(0.0, 0.0, 0.6);

	uniform color COLOR_DIFFUSE  = color(0.5, 0.5, 0.5);
	uniform color COLOR_SPECULAR = color(0.5, 0.5, 0.5);
) {
	// Create terrain.
    float magnitude = RidgedMultifractal(
		(P + terrainOffset) * terrainFrequency, 7, 2.5, 0.9, 0.8, 5, 8
	);
	
	float height = magnitude * terrainHeightCoef * distance(zcomp(P), 100) / 1000.0;

    P += height * normalize(N);
    N = calculatenormal(P);

	// Get values for terrain types.
	float cliffs = ycomp(normalize(N));

	float ocean  = smoothstep(seaLevel - TRANSITION_OCEAN, seaLevel, height);
	float beach  = smoothstep(seaLevel, seaLevel + TRANSITION_BEACH, height);

	float forest =        fBm(P * forestFrequency, 6, 2.8, 0.5);
	float waves  = turbulence(P *   waveFrequency, 6, 2.0, 0.5);

	// Bump the waves upwards.
	P += UP * ONE_MINUS(waves) * ONE_MINUS(ocean) * waveHeight;
	N = calculatenormal(P);

	// Calculate color.
	color outColor   = COLOR_LAND;
	color oceanColor = mix(COLOR_WAVES, COLOR_OCEAN, waves);

	outColor  = mix(COLOR_FOREST, outColor, forest);
	outColor  = mix(COLOR_CLIFFS, outColor, cliffs);
	outColor  = mix(COLOR_BEACH,  outColor, beach );
	outColor  = mix(oceanColor,   outColor, ocean );

	// Calculate lighting.
	normal Nf = faceforward(normalize(N), I);
	float roughness = mix(0.1, 0.01, ocean);
	color diff = COLOR_DIFFUSE  * diffuse(Nf);
	color spec = COLOR_SPECULAR * specular(Nf, normalize(-I), roughness);

	outColor *= diff + spec;

	// Add fog.
	float depth = abs(v - 1);
	outColor = mix(outColor, COLOR_FOG, depth * fogIntensity);

    Ci = outColor;
    Oi = Os;
}
