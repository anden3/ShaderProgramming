surface enkelshader(
	float freq=8.0;
	float top=1.0;
		
	color blue=(0.0, 0.0, 1.0);
	color yellow=(1.0, 1.0, 0.0);
	color white=(1.0, 1.0, 1.0);
) {
	float A = smoothstep(0.3, 0.7, mod(s * freq, 2));
	float B = smoothstep(1.3, 1.7, mod(s * freq, 2));

	Ci = mix(white,
		mix(blue, yellow, A - B),
		smoothstep(top, top + 0.3, t * freq)
	);
	Oi = Os;
}
