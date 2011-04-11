// Used for shadow lookup
varying vec4 ShadowCoord;
uniform mat4 shadowTransMatrix;
uniform vec4 lightPosition;
uniform vec4 lightLook;
varying vec4 lightDir, eyeVec;
varying vec3 vertexNormal;
varying vec3 vertexNormalWorld;

void main()
{
		eyeVec = gl_ModelViewMatrix * gl_Vertex; // Not sure why this is needed
		ShadowCoord = shadowTransMatrix * eyeVec;
		vertexNormal = normalize(gl_NormalMatrix * gl_Normal);
		vertexNormalWorld = gl_Normal;
		lightDir = normalize(lightLook - lightPosition);
		gl_Position = ftransform();
		gl_FrontColor = gl_Color;
}