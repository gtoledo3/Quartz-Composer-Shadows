varying vec3		M, L;
varying vec4		q;

uniform mat4		shadowTransMatrix;
uniform vec3		lightPosition;
uniform vec3		lightLook;

void main(void)
{
	vec4 eyeCoord = gl_ModelViewMatrix * gl_Vertex;

	L = normalize(  lightPosition - lightLook);
	M = gl_Normal;
	q = shadowTransMatrix * eyeCoord;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_FrontColor = gl_Color;
}
