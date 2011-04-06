varying vec3		N, V, L, M;

uniform vec3		lightPosition;
uniform vec3		lightLook;

void main(void)
{
	vec4 eyeCoord = gl_ModelViewMatrix * gl_Vertex;
	V = normalize( -eyeCoord.xyz );
	L = normalize(  lightPosition - lightLook);
	N = gl_NormalMatrix * gl_Normal;
	M = gl_Normal;
	gl_Position = ftransform();
	gl_FrontColor = gl_Color;
}
