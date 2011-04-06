uniform float pcfScale;
uniform int pcfSamples;
uniform int texMapSize;
uniform sampler2DShadow depthTexture;
uniform float bottomLine;		// We really shouldnt need this but we do :(

varying vec3		N, V, L, M;
varying vec4		q;


float computeBasic() {
	vec3 coord = 0.5 * (q.xyz / q.w + 1.0);
	float qw = q.z/q.w;
	if ( qw <= shadow2D( depthTexture, coord ).r){
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
	float qw = q.z / q.w + bottomLine;

	for (y = bottom; y <= top; y += 1.0){
		for (x = bottom; x <= top; x += 1.0){
			vec2 t = vec2(x,y);
			t = t * texscale * pcfScale;
			coord.x += t.x;
			coord.y += t.y;
			if (qw <= shadow2D(depthTexture, coord).r) 
				sum += 1.0;
		}
	}
	
	return sum / float(pcfSamples * pcfSamples);
}



void main(void) {

	vec3 normal = normalize( N );
	vec3 R = -normalize( reflect( L, normal ) );

	//vec4 ambient = gl_FrontLightProduct[0].ambient;
	//vec4 diffuse = gl_FrontLightProduct[0].diffuse * max(dot( normal, L), 0.0);
	//vec4 specular = gl_FrontLightProduct[0].specular * pow(max(dot(R, V), 0.0), gl_FrontMaterial.shininess);
	//gl_FragColor = (ambient + (0.2 + 0.8 * shadow) * diffuse) + specular * shadow
	
	vec4 diffuse = gl_Color * max(dot( M, L), 0.0);
	
	float shadow = computePCF();
	
	gl_FragColor = (0.2 + 0.8 * shadow) * diffuse;
	//gl_FragColor = gl_Color * shadow;

}
