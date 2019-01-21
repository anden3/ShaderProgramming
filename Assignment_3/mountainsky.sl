surface mountainsky(
	color startcolor = (0.14, 0.34, 0.63);
	color hazecolor  = (0.7,  1.0,  1.0 );
) {
	color zerocol = color(0, 0, 0);
	
	float basecol =     1 - clamp((ycomp(P) - 200) / 500, 0, 1);
	float hazecol = pow(1 - clamp((ycomp(P) - 200) / 300, 0, 1), 3);

	color outcol  = mix(zerocol, startcolor, basecol);
	      outcol += mix(zerocol, hazecolor,  hazecol);
	
	point P1 = point(0, 0, 0);
	point P2 = ((u - 0.5) * 0.5, (v - 0.5) * 0.5, 0);
	point P3 = point(0, v, 0);

	float dist1 = distance(P1, P2) * 1.8;
	float dist2 = distance(P1, P3) * 1.8;
	float dist = dist1 * dist2;

	dist = smoothstep(0.015, 0.3, dist);
	dist = clamp(dist, 0.01, 1.0);
			
	// Ci = outcol;
	Ci = color(0.4, 0.2, 0.1) / dist;
	Oi = Os;
} 

