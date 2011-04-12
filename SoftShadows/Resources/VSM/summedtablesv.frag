uniform int texWidth; // Should have size I imagine
uniform int Ni;	// texels along 2 ^ i (so we pre power)

// TODO - this is practically identical to horiz therefore we should just have a swap variable or something

uniform sampler2D texture;

void main (void) {
	// vertical Pass 
	vec2 s = gl_TexCoord[0].st;
	vec2 sd = s;
	sd.y = sd.y + ( 1.0/ float(texWidth) * float(Ni) );
	vec4 c = texture2D(texture, s) + texture2D(texture, sd);
	
	gl_FragColor = c;
	
	// Now we SWAP textures

}

