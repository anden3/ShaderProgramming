#define snoise(p) (2 * (float noise(p)) - 1)

float fBm (point p; uniform float octaves, lacunarity, gain)
{
  uniform float amp = 1;
  varying point pp = p;
  varying float sum = 0;
  uniform float i;
  
  for (i = 0;  i < octaves;  i += 1) {
    sum += amp * snoise (pp);
    amp *= gain;
    pp *= lacunarity;
  }
  return sum;
}

float turbulence(point p; uniform float octaves, lacunarity, gain)
{
  uniform float amp = 1;
  varying point pp = p;
  varying float sum = 0;
  uniform float i;
  
  for (i = 0;  i < octaves;  i += 1) {
    sum += abs(amp * snoise (pp));
    amp *= gain;
    pp *= lacunarity;
  }
  return sum;
}

void voronoi_f1f2_2d (float ss, tt; output float f1; output float spos1, tpos1; output float f2; output float spos2, tpos2;)
{
  float jitter=1.0;
  float sthiscell = floor(ss)+0.5;
  float tthiscell = floor(tt)+0.5;
  f1 = f2 = 1000;
  uniform float i, j;
  for (i = -1;  i <= 1;  i += 1) {
	float stestcell = sthiscell + i;
	for (j = -1;  j <= 1;  j += 1) {
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
	  } else if (dist < f2) {
		f2 = dist;
		spos2 = spos;
		tpos2 = tpos;
	  }
	}
  }
  f1 = sqrt(f1);  f2 = sqrt(f2);
}


surface stars()
{
	float f1;
	voronoi_f1f2_2d(s,t,f1,0,0,0,0,0);

	f1 = smoothstep(0.02, 0.07, f1) + 0.01;
	color C = color(0.2, 0.1, 0.03) / f1;

	float cloud1 = fBm(P / 20.0, 6, 3.0, 0.5);
	cloud1 = clamp(cloud1, 0.0, 1.0);
	color cloud1Color = color(0.0, 0.0, 1.0) * cloud1;

	float cloud2 = turbulence(P / 15.0, 6, 3.0, 0.5);
	cloud2 = clamp(cloud2, 0.0, 1.0);
	color cloud2Color = color(1.0, 0.0, 0.0) * cloud2;

	color cloudColor = mix(cloud1Color, cloud2Color, 0.5);
	
	Ci = cloudColor;
	// Ci = C;
	Oi = Os;
} 
