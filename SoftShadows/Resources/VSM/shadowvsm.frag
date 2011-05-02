uniform sampler2D	ShadowMap;
uniform float		minVariance;
uniform float		ambientLevel;
uniform float		lightAttenuation;
uniform int			shadowMapSize;
uniform float		filterSize;
uniform float		lightSize;
uniform vec4		lightPosition;

varying vec4		ShadowCoord;
varying vec4		lightDir, eyeVec;
varying vec3		vertexNormal;
varying vec3		vertexNormalWorld;


// Useful Globals

vec3 Q;	// Transformed point in light space
float texelStep = 1.0 / float(shadowMapSize);
float g_DistributeFactor = 1024.0;
int pcfSamples = 8;
float pcfSamples2 = 64.0;

// This is somewhat specific to the sub objects within our QC File so might need to be changed
// TODO  - Minus light dir do we think?

float lightLevel() {
	float d = Q.z - lightPosition.z;
	float attenuation = 1.0 / (d * d * lightAttenuation);
	return attenuation * max(dot(vertexNormalWorld, -lightDir.xyz), 0.0);
}


float lintexelStep(float min, float max, float v)  {  
  return clamp((v - min) / (max - min), 0.0, 1.0);  
}  

float ReduceLightBleeding(float p_max, float Amount)  {  
  // Remove the [0, Amount] tail and linearly rescale (Amount, 1].  
   return lintexelStep(Amount, 1.0, p_max);  
}  


// PCSS FUNCTIONS
// --------------

float FindBlocker() {

	float receiver = Q.z;
	float searchWidth = lightSize * receiver;
	
	float blockerSum = 0.0;
	float blockerCount = 0.0;
	

	// Was random but moved to be the same as the pcf texelStep
	
	float tpcf = float(pcfSamples) /2.0 - 0.5;	
	
	for(float i = -tpcf; i <= tpcf; i += 1.0) {
		for(float j = -tpcf; j <= tpcf; j += 1.0) {

			vec2 r = vec2(i * texelStep, j * texelStep) * searchWidth;
			vec2 uv = vec2(Q.x + r.x, Q.y + r.y);
			float s = texture2D(ShadowMap, uv.xy).r;
			
			if ( s <= receiver){
				blockerSum += s;
				blockerCount += 1.0;
			}
		}
	}

	return blockerSum / blockerCount;
}

float EstimatePenumbra(float blocker) {
       // receiver depth
       float receiver = Q.z;
       // estimate penumbra using parallel planes approximation
       return (receiver - blocker) * lightSize / blocker;
}



// Box Sample Blur - WITH SUMMED TABLES!

vec4 btex2DSummed(vec2 uv) {
	float ss = texelStep * filterSize / 2.0;
	float xmax = uv.x - ss;
	float xmin = uv.x + ss;
	
	float ymax = uv.y - ss;
	float ymin = uv.y + ss;

	vec4 total = texture2D(ShadowMap, vec2(xmax,ymax)) -  texture2D(ShadowMap, vec2(xmax,ymin)) 
	- texture2D(ShadowMap, vec2(xmin,ymax)) + texture2D(ShadowMap, vec2(xmin,ymin));

	return total / (filterSize * filterSize);
}


vec4 btex2D(vec2 uv, float filter) {

	float tpcf = float(pcfSamples) /2.0 - 0.5;	
	float sum = 0.0;
	float sum2 = 0.0;
	float step = texelStep * filter;
	
	//tpcf = int( ceil(float(pcfSamples) * filterWidth));
	
	for (float i=-tpcf; i <= tpcf; i+= 1.0){
		for (float j=-tpcf; j <= tpcf; j+=1.0){
			vec2 r = vec2( i * step, j * step);
			
			vec3 coord = Q;
			coord.x += r.x;
			coord.y += r.y;
			
			float dd = texture2D(ShadowMap,coord.xy).r;
			float ddd = texture2D(ShadowMap,coord.xy).g;
	
			if ( Q.z <= dd)  {
				sum += dd;
				sum2 += ddd; 
			}
			else {
				sum += 1.0 / dd * lightAttenuation;
				sum2 += 1.0 / ddd * lightAttenuation;
			}

		}
	}
	return vec4( sum / pcfSamples2, sum2 / pcfSamples2, 0.0,0.0);
}


float chebyshevUpperBoundPCSS() {

	float blocker = FindBlocker();

	if(blocker == 0.0)
		return 1.0;
		
	float penumbra = EstimatePenumbra(blocker);
	
	vec2 moments = texture2D(ShadowMap,Q.xy).rg;//btex2D(Q.xy,penumbra);

	if (Q.z <= moments.x)
		return 1.0 ;

	float variance = moments.y - (moments.x * moments.x);
	variance = max(variance, minVariance);

	float d = Q.z - moments.x ;
	float p_max = variance / (variance + d * d);
	
	return p_max;	
}




// Upper Bound VSM Shadow code

float chebyshevUpperBoundSummed()
{
	// We retrive the two moments previously stored (depth and depth*depth)
	// these are split over r,g and b,a
	
	vec4 moments = btex2DSummed(Q.xy);
//	float FactorInv = 1.0 / g_DistributeFactor;  

	//vec4 moments = vec4(splits.y * FactorInv + splits.x, splits.w * FactorInv + splits.z, 0.0,0.0);
	//vec4 moments = vec4(splits.x * FactorInv + splits.y, splits.z * FactorInv + splits.w,0.0,0.0);
	
	moments.x += 0.5;	// Since using SUMMED Tables we need to adjust
	moments.y += 0.5;
	
	//vec2 moments = texture2D(ShadowMap,Q.xy).rg;
	
	// Surface is fully lit. as the current fragment is before the light occluder
	// Hardly ever occurs because the distances will always be greater or very close to equal
	if (Q.z <= moments.x)
		return 1.0 ;

	// The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
	// How likely this pixel is to be lit (p_max)
	float variance = moments.y - (moments.x * moments.x);
	variance = max(variance, minVariance);

	float d = Q.z - moments.x ;
	float p_max = variance / (variance + d * d);
	
	return p_max;
	
	//return max (1.0 - p_max, 0.0);
}


void main()
{	
	Q = 0.5 * (ShadowCoord.xyz / ShadowCoord.w + 1.0);

	float shadow = ReduceLightBleeding(chebyshevUpperBoundPCSS(),0.15);
	float litFactor = (1.0 - ambientLevel) * (shadow) * lightLevel();
	//gl_FragColor = gl_Color * smoothtexelStep(ambientLevel,1.0,max(lightLevel(),shadow));
	gl_FragColor = gl_Color * (litFactor + ambientLevel);
}
