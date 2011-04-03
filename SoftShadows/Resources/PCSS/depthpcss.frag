varying vec4 v_position;


void main()
{
	float depth = v_position.z / v_position.w ;
	
	gl_FragColor = vec4(gl_Color.rgb, depth);
}