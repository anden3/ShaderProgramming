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

surface mountain(float Ka = 0, Kd = 1) {
    float magnitude = RidgedMultifractal(
		(P + 100) * 0.002, 7, 2.5, 0.9, 0.8, 5, 8
	) * 120.00001;
	
	float mountainAtt = distance(zcomp(P), 100) / 1000.0;

    P += magnitude * mountainAtt * normalize(N);
    N = calculatenormal(P);

	point PP = P;
	PP += sin(u) * normalize(N) * 2;
	N = calculatenormal(PP);

    normal Nf = faceforward(normalize(N), I);
	color Diffuse = Cs * (Kd * diffuse(Nf));

	float snow = ycomp(normalize(N));

	color outcolor = Diffuse * mix(color(1, 1, 1), color(0, 0.6, 0.2), snow);
	outcolor = mix(color(0, 0, 1), outcolor, smoothstep(17, 20, magnitude * mountainAtt));
    
    Ci = outcolor; 
    Oi = Os;
}
