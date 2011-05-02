uniform sampler2D sceneTex; // the texture with the scene you want to blur
uniform float rt_w;
uniform float blurAmount;
varying vec2 vTexCoord;
 
float blurSize = 1.0 / rt_w * blurAmount;

void main(void)
{
   vec4 sum = vec4(0.0);
 
   // blur in y (vertical)
   // take nine samples, with the distance blurSize between them
   sum += texture2D(sceneTex, vec2(vTexCoord.x - 4.0 * blurSize, vTexCoord.y)) * 0.05;
   sum += texture2D(sceneTex, vec2(vTexCoord.x - 3.0 * blurSize, vTexCoord.y)) * 0.09;
   sum += texture2D(sceneTex, vec2(vTexCoord.x - 2.0 * blurSize, vTexCoord.y)) * 0.12;
   sum += texture2D(sceneTex, vec2(vTexCoord.x - blurSize, vTexCoord.y)) * 0.15;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
   sum += texture2D(sceneTex, vec2(vTexCoord.x + blurSize, vTexCoord.y)) * 0.15;
   sum += texture2D(sceneTex, vec2(vTexCoord.x + 2.0 * blurSize, vTexCoord.y)) * 0.12;
   sum += texture2D(sceneTex, vec2(vTexCoord.x + 3.0 * blurSize, vTexCoord.y)) * 0.09;
   sum += texture2D(sceneTex, vec2(vTexCoord.x + 4.0 * blurSize, vTexCoord.y)) * 0.05;
 
   gl_FragColor = sum;
}
