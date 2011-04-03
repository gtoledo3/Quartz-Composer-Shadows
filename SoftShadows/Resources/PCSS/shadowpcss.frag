uniform float pcfScale;
uniform int pcfSamples;
uniform int texMapSize;
uniform sampler2DShadow depthTexture;
uniform float bottomLine;		// We really shouldnt need this but we do :(

varying vec3		N, V, L, M;
varying vec4		q;

vec2 rand(in vec2 coord) //generating random noise
{
	float noiseX = (fract(sin(dot(coord ,vec2(12.9898,78.233))) * 43758.5453));
	float noiseY = (fract(sin(dot(coord ,vec2(12.9898,78.233)*2.0)) * 43758.5453));
	return vec2(noiseX,noiseY)*0.004;
}

float computeBasic() {
	vec3 coord = 0.5 * (q.xyz / q.w + 1.0);
	float qw = q.z/q.w;
	if ( qw - shadow2D( depthTexture, coord ).r < bottomLine){
		return 1.0;
	}
	return 0.0;
}


float computePCF() {
	float sum = 0.0;
	float x =0.0;
	float y = 0.0;
	float texscale = 1.0 / float(texMapSize);
	vec3 coord = 0.5 * (q.xyz / q.w + 1.0);
	float bottom = 0.5 - float(pcfSamples) / 2.0;
	float top = -bottom;
	float qw = q.z / q.w;

	for (y = bottom; y <= top; y += 1.0){
		for (x = bottom; x <= top; x += 1.0){
			vec2 t = vec2(x,y);
			t = t * texscale * pcfScale;
			coord.x += t.x;
			coord.y += t.y;
			if (qw <= shadow2D(depthTexture, coord).r + bottomLine) 
				sum += 1.0;
		}
	}
	
	return sum / float(pcfSamples * pcfSamples);
}



void main(void) {

/*	vec3 normal = normalize( N );
	vec3 R = -normalize( reflect( L, normal ) );

	//vec4 ambient = gl_FrontLightProduct[0].ambient;
	//vec4 diffuse = gl_FrontLightProduct[0].diffuse * max(dot( normal, L), 0.0);
	//vec4 specular = gl_FrontLightProduct[0].specular * pow(max(dot(R, V), 0.0), gl_FrontMaterial.shininess);
	//gl_FragColor = (ambient + (0.2 + 0.8 * shadow) * diffuse) + specular * shadow
	
	vec4 diffuse = gl_Color * max(dot( M, L), 0.0);
	
	if (q.w > 0.0) {
		float shadow = computePCF();
	
		gl_FragColor = shadow * diffuse;
	}
	else {
		gl_FragColor = diffuse;
	}*/
	float shadow = computePCF();
	gl_FragColor = vec4(shadow,shadow,shadow,1.0);
}
