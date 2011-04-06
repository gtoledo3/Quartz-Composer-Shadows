varying vec3 L, M;

void main()
{
	gl_FragColor = gl_Color * max(dot( M, L), 0.0);
	 
} 
