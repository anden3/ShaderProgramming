surface enkelshader(
	float freq=8.0;
	float top=1.0;
		
	color blue=(0.0, 0.0, 1.0);
	color yellow=(1.0, 1.0, 0.0);
	color white=(1.0, 1.0, 1.0);
) {
	Ci = mix(blue, yellow, step(1, mod(s * freq, 2)));
	Oi = Os;
}
