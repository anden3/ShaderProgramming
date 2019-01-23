#define snoise(p) (2 * (float noise(p)) - 1)

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
	uniform color COLOR_LAND   = (0.0, 0.8, 0.3);
	uniform color COLOR_FOREST = (0.0, 0.3, 0.0);
	uniform color COLOR_CLIFFS = (0.6, 0.6, 0.6);
	uniform color COLOR_BEACH  = (1.0, 0.9, 0.8);
	uniform color COLOR_OCEAN  = (0.0, 0.0, 1.0);
	uniform color COLOR_WAVES  = (0.0, 0.0, 0.6);

	uniform color COLOR_DIFFUSE  = (0.5, 0.5, 0.5);
	uniform color COLOR_SPECULAR = (0.5, 0.5, 0.5);

) {
    float magnitude = RidgedMultifractal(
		(P + 100) * 0.003, 7, 2.5, 0.9, 0.8, 5, 8
	) * 120.00001;
	
	float height = magnitude * distance(zcomp(P), 100) / 1000.0;

    P += height * normalize(N);
    N = calculatenormal(P);

	float forest = fBm(P / 20.0, 6, 2.8, 0.5);
	float cliffs = ycomp(normalize(N));
	float ocean  = smoothstep(17, 20, height);
	float beach  = smoothstep(20, 21, height);
	float waves  = turbulence(P / 20.0, 6, 2, 0.5);

	float roughness = mix(0.1, 0.01, ocean);

	P += vector(0, 1, 0) * (1 - waves) * 1;
	N = calculatenormal(P);

	normal Nf = faceforward(normalize(N), I);
	color diff = COLOR_DIFFUSE * diffuse(Nf);
	color spec = COLOR_SPECULAR * specular(Nf, normalize(-I), roughness);

	color oceanColor = mix(COLOR_WAVES, COLOR_OCEAN, waves);
	color outColor = COLOR_LAND;

	outColor = mix(COLOR_FOREST, outColor, forest);
	outColor = mix(COLOR_CLIFFS, outColor, cliffs);
	outColor = mix(COLOR_BEACH,  outColor, beach );
	outColor = mix(oceanColor,   outColor, ocean );

	point P1 = point(0, 0, 0);
	point P2 = point(0, (v - 1) * 0.5, 0.0);

	float dist = distance(P1, P2) * 1.8;
	dist = clamp(smoothstep(0.35, 0.5, dist), 0.01, 1.0);
    
    Ci = mix(outColor * (diff + spec), (1, 1, 1), dist * 0.5);
    Oi = Os;
}
