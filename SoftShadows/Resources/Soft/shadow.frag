uniform sampler2D ShadowMap;
uniform float maxVariance;
varying vec4 ShadowCoord;
varying vec4 lightDir, eyeVec;
varying vec3 vertexNormal;

vec3 ShadowCoordPostW;

// This is somewhat specific to the sub objects within our QC File so might need to be changed
float lighting() {
	return  max(dot(vertexNormal, lightDir.xyz), 0.0);
}

float chebyshevUpperBound()
{
	// We retrive the two moments previously stored (depth and depth*depth)
	vec2 moments = texture2D(ShadowMap,ShadowCoordPostW.xy).rg;
	
	// Surface is fully lit. as the current fragment is before the light occluder
	// Hardly ever occurs because the distances will always be greater or very close to equal
	if (ShadowCoordPostW.z <= moments.x)
		return 0.0 ;

	// The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
	// How likely this pixel is to be lit (p_max)
	float variance = moments.y - (moments.x * moments.x);
	variance = max(variance, maxVariance);

	float d = ShadowCoordPostW.z - moments.x ;
	float p_max = variance / (variance + d * d);

	return p_max;
}


void main()
{	
	ShadowCoordPostW = 0.5 * (ShadowCoord.xyz / ShadowCoord.w + 1.0);

	float shadow = chebyshevUpperBound();
	float diffuse = lighting();
	gl_FragColor = gl_Color * (1.0 - shadow);
  
}
