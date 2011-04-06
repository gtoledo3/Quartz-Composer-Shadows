
uniform int					pcfSamples;
uniform int					texMapSize;
uniform sampler2DShadow		depthTexture;
uniform sampler2D			rawDepth;
uniform float				bottomLine;	// We really shouldnt need this but we do :(
uniform float				lightSize;

varying vec3		N, V, L, M;
varying vec4		q,E;

uniform float attenuation;

float att = attenuation * attenuation;

vec4 qw = q / q.w;
float InvShadowSize = 1.0/float(texMapSize);

// UTILITY FUNCTIONS
// -----------------

vec2 rand(in vec2 coord) //generating random noise
{
	float noiseX = (fract(sin(dot(coord ,vec2(12.9898,78.233))) * 43758.5453));
	float noiseY = (fract(sin(dot(coord ,vec2(12.9898,78.233)*2.0)) * 43758.5453));
	return vec2(noiseX,noiseY)*0.004;
}



// BASIC SHADOW MAP
// ----------------

float computeBasicProj() {	
	return shadow2DProj( depthTexture, q).w;
}

float computeRaw() {

	vec4 p = qw;
	p.z += bottomLine;
	float dist = texture2D(rawDepth, p.st).z;
	if (dist <= p.z) {
		return 0.0;
	}
	return 1.0;
}


// BASIC PCF
// ---------

// Its worth noting that with the compare_to_r texture parameter, doing shadow lookups
// returns EITHER 0 or 1. It may be worth passing two matrices and two texures!

float computePCF(float filterWidth) {
	
	float tpcf = float(pcfSamples) /2.0 - 0.5;	
	float sum = 0.0;
	
	//tpcf = int( ceil(float(pcfSamples) * filterWidth));
	
	for (float i=-tpcf; i <= tpcf; i+= 1.0){
		for (float j=-tpcf; j <= tpcf; j+=1.0){
			vec2 r = vec2( i * InvShadowSize * filterWidth, j * InvShadowSize * filterWidth);
			
			vec4 coord = qw;
			coord.x += r.x;
			coord.y += r.y;
			
			if ( qw.z <= texture2D(rawDepth,coord.xy).z + bottomLine)  {
				sum += 1.0;
			}
			else {
				sum += filterWidth * att;
			}

			
		}
		
	}
	return sum / float(pcfSamples * pcfSamples);
}


float computePCF2( in vec4 tc, float filterWidth )
{
    //
    //  simple bilinear filtering
    //  first bring up to whole coords, get fractionals, and then drop back to normalized coords
    //

    tc *= float(texMapSize);

    vec4 sc = floor( tc ),
          fractional = tc - sc;
    
    sc *= InvShadowSize;

    
    float x1 = shadow2DProj( depthTexture, sc ).r,
          x2 = shadow2DProj( depthTexture, sc + vec4( InvShadowSize,0,0,0 )).r,
          x3 = shadow2DProj( depthTexture, sc + vec4( 0,InvShadowSize,0,0 )).r,
          x4 = shadow2DProj( depthTexture, sc + vec4( InvShadowSize,InvShadowSize,0,0 )).r,
          a  = mix( x2, x1, fractional.x ),
          b  = mix( x4, x3, fractional.x );

    return mix( b, a, fractional.y );
}


// PCSS FUNCTIONS
// --------------

float FindBlocker() {

	float receiver = qw.z;
	float searchWidth = lightSize * receiver;
	
	float blockerSum = 0.0;
	float blockerCount = 0.0;
	

	// Was random but moved to be the same as the pcf step
	
	float tpcf = float(pcfSamples) /2.0 - 0.5;	
	
	for(float i = -tpcf; i <= tpcf; i += 1.0) {
		for(float j = -tpcf; j <= tpcf; j += 1.0) {

			vec2 r = vec2(i * InvShadowSize, j * InvShadowSize) * searchWidth;
			vec4 uv = vec4(qw.x + r.x, qw.y + r.y, qw.z,q.w);
			float s = texture2D(rawDepth, uv.xy).z;
			
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
       float receiver = qw.z;
       // estimate penumbra using parallel planes approximation
       return (receiver - blocker) * lightSize / blocker;
}


float computePCSS() {

	float blocker = FindBlocker();

	if(blocker == 0.0)
		return 1.0;
		
	
	float penumbra = EstimatePenumbra(blocker);

	//return penumbra;

	return computePCF(penumbra);
}


void main(void) {

	float shadow = computePCSS();
	gl_FragColor = vec4(shadow,shadow,shadow,1.0);
}
