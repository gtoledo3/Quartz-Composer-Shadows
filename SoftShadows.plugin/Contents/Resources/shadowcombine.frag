uniform sampler2D	shadowTexture;
uniform sampler2D	baseTexture;

void main() {
	
	float shadow = texture2D(shadowTexture, gl_TexCoord[0].st).r;
	vec4 base = texture2D(baseTexture, gl_TexCoord[0].st);
	gl_FragColor = base * shadow;

}