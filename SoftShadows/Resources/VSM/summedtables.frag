uniform int texWidth;
uniform int Ni;	// texels along 2 ^ i (so we pre power)

uniform sampler2D texture;

void main (void) {
	// Horizontal Pass
	vec2 s = gl_TexCoord[0].st;
	vec2 sd = s;
	sd.x = sd.x + (1.0/ float(texWidth) * float(Ni));
	vec4 c = texture2D(texture, s) + texture2D(texture, sd);
	
	gl_FragColor = c;
	
	// Now we SWAP textures

}

