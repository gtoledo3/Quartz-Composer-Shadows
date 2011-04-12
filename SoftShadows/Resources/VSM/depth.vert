varying vec4 v_position;
varying float tDepth;

uniform float far;

void main()
{
		//v_position = gl_ModelViewMatrix * gl_Vertex;
		tDepth = -v_position.z/far;
		gl_Position = ftransform();
		v_position = gl_Position;
}