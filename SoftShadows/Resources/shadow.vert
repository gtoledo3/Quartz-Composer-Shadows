// Used for shadow lookup
varying vec4 ShadowCoord;
varying vec3 normal, lightDir, eyeVec;

uniform mat4 shadowTransMatrix;

void main()
{

		normal = gl_NormalMatrix * gl_Normal;
		vec3 vVertex = vec3(gl_ModelViewMatrix * gl_Vertex);
		lightDir = vec3(gl_LightSource[0].position.xyz - vVertex);
		eyeVec = -vVertex;

     	ShadowCoord =  shadowTransMatrix * gl_Vertex;
	  
		gl_Position = ftransform();

		gl_FrontColor = gl_Color;
		
		gl_TexCoord[0] = gl_MultiTexCoord0;
}
