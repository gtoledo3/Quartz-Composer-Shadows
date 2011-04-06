
varying vec3 normal;
varying vec3 vpos;

void main()
{	
	// vertex normal
	normal = normalize(gl_NormalMatrix * gl_Normal);
	
	gl_FrontColor = gl_Color;
	// vertex position
	vpos = vec3(gl_ModelViewMatrix * gl_Vertex);

	// Pass texture units across
	gl_TexCoord[0] =  gl_MultiTexCoord0;
	gl_TexCoord[1] =  gl_MultiTexCoord1;
	
	// vertex position
	gl_Position = ftransform();
	
}
