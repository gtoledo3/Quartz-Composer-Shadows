varying vec3		N, V, L;
varying vec4		q,E;

uniform mat4		shadowTransMatrix;
uniform vec3		lightPosition;
uniform vec3		lightLook;

void main(void)
{
	vec4 eyeCoord = gl_ModelViewMatrix * gl_Vertex;
	V = normalize( -eyeCoord.xyz );
	L = normalize(  lightPosition - lightLook);
	N = gl_NormalMatrix * gl_Normal;
	E = eyeCoord;
	q = shadowTransMatrix * eyeCoord;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_FrontColor = gl_Color;
}
