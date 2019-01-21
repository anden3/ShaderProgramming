surface enkelshader(
	float freq=8.0;
	float top=1.0;

	color diffcolor=(0.6, 0.6, 0.6);
	color speccolor=(1.0, 1.0, 1.0);

	float bumpDepth=0.5;
	float noiseDepth=1.0;
	float roughness=0.1;
		
	color blue=(0.0, 0.0, 1.0);
	color yellow=(1.0, 1.0, 0.0);
	color white=(1.0, 1.0, 1.0);
) {
	// Calculate blue/yellow mix.
	float A = smoothstep(0.3, 0.7, mod(s * freq, 2));
	float B = smoothstep(1.3, 1.7, mod(s * freq, 2));
	color C = mix(blue, yellow, A - B);

	// Calculate white spot.
	float Top = smoothstep(top, top + 0.3, t * freq);
	C = mix(white, C, Top);

	// Calculate bump mapping.
	float bumpVal = 1 - (A - B);
	vector bumpMap = N * bumpVal * bumpDepth;
	vector noiseMap = N * bumpVal * noise(P) * noiseDepth;
	
	point pp = P;
	pp += bumpMap;
	pp += noiseMap;
	N = calculatenormal(pp);

	// Calculate lighting.
	normal Norm = normalize(N);
	vector V = normalize(-I);

	color diff = diffcolor * diffuse(Norm);
	color spec = speccolor * specular(Norm, V, roughness);

	Ci = C * (diff + spec);
	Oi = Os;
}
