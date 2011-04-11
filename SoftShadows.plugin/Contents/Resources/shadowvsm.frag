uniform sampler2D ShadowMap;
uniform float minVariance;
uniform float blurAmount;
uniform float ambientLevel;
uniform float lightAttenuation;
varying vec4 ShadowCoord;
uniform vec4 lightPosition;
varying vec4 lightDir, eyeVec;
varying vec3 vertexNormal;
varying vec3 vertexNormalWorld;

vec3 ShadowCoordPostW;

// This is somewhat specific to the sub objects within our QC File so might need to be changed
// TODO  - Minus light dir do we think?

float lightLevel() {
	float d = ShadowCoordPostW.z - lightPosition.z;
	float attenuation = 1.0 / (d * d * lightAttenuation);
	return attenuation * max(dot(vertexNormalWorld, -lightDir.xyz), 0.0);
}

float linstep(float min, float max, float v)  
{  
  return clamp((v - min) / (max - min), 0.0, 1.0);  
}  

float ReduceLightBleeding(float p_max, float Amount)  
{  
  // Remove the [0, Amount] tail and linearly rescale (Amount, 1].  
   return linstep(Amount, 1.0, p_max);  
}  

// Box Sample Blur

vec4 btex2D(vec2 uv, float radius, float steps)
{
  float stepSize = 2.0 * radius / steps;
  uv.xy -= radius;

  vec4 total = vec4(0, 0, 0, 0);
  for (float x = 0.0; x < steps; x+=1.0)
	 for (float y = 0.0; y < steps; y+=1.0)
		total += texture2D(ShadowMap, vec2(uv.xy + vec2(x * stepSize, y * stepSize)));

  return total / (steps * steps);
}


// Upper Bound VSM Shadow code

float chebyshevUpperBound()
{
	// We retrive the two moments previously stored (depth and depth*depth)
	
	vec4 moments = btex2D(ShadowCoordPostW.xy,blurAmount,8.0);
	
	//vec2 moments = texture2D(ShadowMap,ShadowCoordPostW.xy).rg;
	
	// Surface is fully lit. as the current fragment is before the light occluder
	// Hardly ever occurs because the distances will always be greater or very close to equal
	if (ShadowCoordPostW.z <= moments.x)
		return 1.0 ;

	// The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
	// How likely this pixel is to be lit (p_max)
	float variance = moments.y - (moments.x * moments.x);
	variance = max(variance, minVariance);

	float d = ShadowCoordPostW.z - moments.x ;
	float p_max = variance / (variance + d * d);
	return p_max;
}


void main()
{	
	ShadowCoordPostW = 0.5 * (ShadowCoord.xyz / ShadowCoord.w + 1.0);

	float shadow = ReduceLightBleeding (chebyshevUpperBound(),0.1);
	float litFactor = (1.0 - ambientLevel) * shadow * lightLevel();
	//gl_FragColor = gl_Color * smoothstep(ambientLevel,1.0,max(lightLevel(),shadow));
	gl_FragColor = gl_Color * (litFactor + ambientLevel);
}
