// Reverse a summed area table so we may get the texture back
uniform int texSize;
uniform sampler2D texture;

float step = 1.0 / float(texSize);

void main (void) {
	vec2 s = gl_TexCoord[0].st;		// Four corners of the rectangle
	vec2 tl = vec2(s.x-step,s.y-step);
	vec2 bl = vec2(s.x-step,s.y);
	vec2 tr = vec2(s.x,s.y-step);
	
	vec4 c0 = texture2D(texture, s);
	vec4 c1 = texture2D(texture, bl);
	vec4 c2 = texture2D(texture, tr);
	vec4 c3 = texture2D(texture, tl);
	
	vec4 f = c0 - c1 - c2 + c3;


	gl_FragColor = f;
	
	// Now we SWAP textures

}

