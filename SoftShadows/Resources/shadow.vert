// Used for shadow lookup
varying vec4 ShadowCoord;
uniform mat4 shadowTransMatrix;

void main()
{
		vec4 eyeCoord = gl_ModelViewMatrix * gl_Vertex; // Not sure why this is needed
		ShadowCoord= shadowTransMatrix * eyeCoord;
		gl_Position = ftransform();
		gl_FrontColor = gl_Color;
}
