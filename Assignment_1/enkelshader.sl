surface enkelshader(
	uniform float freq = 8.0;
	uniform float top  = 1.0;

	uniform float bumpDepth  = 0.5;
	uniform float noiseDepth = 1.0;
	uniform float roughness  = 0.1;

	uniform color COLOR_A   = (0.0, 0.0, 1.0);
	uniform color COLOR_B   = (1.0, 1.0, 0.0);
	uniform color COLOR_TOP = (1.0, 1.0, 1.0);

	uniform color COLOR_DIFFUSE  = (0.6, 0.6, 0.6);
	uniform color COLOR_SPECULAR = (1.0, 1.0, 1.0);
) {
	// Calculate color mix for stripes.
	float A = smoothstep(0.3, 0.7, mod(s * freq, 2));
	float B = smoothstep(1.3, 1.7, mod(s * freq, 2));
	color C = mix(COLOR_A, COLOR_B, A - B);

	// Calculate top spot.
	float Top = smoothstep(top, top + 0.3, t * freq);
	C = mix(COLOR_TOP, C, Top);

	// Calculate bump mapping.
	float  bumpVal  = 1 - (A - B);
	vector bumpMap  = N * bumpVal * bumpDepth;
	vector noiseMap = N * bumpVal * noise(P) * noiseDepth;
	
	point pp = P;
	pp += bumpMap;
	pp += noiseMap;
	N = calculatenormal(pp);

	// Calculate lighting.
	normal Norm = normalize(N);
	vector V    = normalize(-I);

	color diff = COLOR_DIFFUSE  * diffuse(Norm);
	color spec = COLOR_SPECULAR * specular(Norm, V, roughness);

	Ci = C * (diff + spec);
	Oi = Os;
}
