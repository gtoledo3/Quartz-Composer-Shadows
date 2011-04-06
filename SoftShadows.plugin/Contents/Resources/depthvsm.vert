varying vec4 v_position;
varying float tDepth;

uniform float far;

void main()
{
		vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
		tDepth = -viewPos.z/far;

		gl_Position = ftransform();
		v_position = gl_Position;
}