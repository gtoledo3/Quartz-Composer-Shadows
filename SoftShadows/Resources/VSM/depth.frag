varying vec4 v_position;
varying float tDepth;

float g_DistributeFactor = 1024.0;  
 
 
void main()
{
	// Is this linear depth? I would say yes but one can't be utterly sure.
	// Could try a divide by the far plane?
	
	float depth = v_position.z / v_position.w ;
	depth = depth * 0.5 + 0.5;			//Don't forget to move away from unit cube ([-1,1]) to [0,1] coordinate system

	vec2 moments = vec2(depth, depth * depth);

	// Adjusting moments (this is sort of bias per pixel) using derivative
	float dx = dFdx(depth);
	float dy = dFdy(depth);
	moments.y += 0.25 * (dx*dx+dy*dy);
	
	// Subtract 0.5 off now so we can get this into our summed area table calc
	
	//moments -= 0.5;
	
	// Split the moments into rg and ba for EVEN MORE PRECISION
	
	/*float FactorInv = 1.0 / g_DistributeFactor;

	gl_FragColor = vec4(floor(moments.x) * FactorInv, fract(moments.x ) * g_DistributeFactor, 
					floor(moments.y)  * FactorInv, fract(moments.y)  * g_DistributeFactor);
	*/

	gl_FragColor = vec4(moments,0.0,0.0);
}