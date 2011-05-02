uniform sampler2D sceneTex; // this should hold the texture rendered by the horizontal blur pass
uniform float rt_h;
uniform float blurAmount;
varying vec2 vTexCoord;
 
float blurSize = 1.0/rt_h * blurAmount;
 
void main(void)
{
   vec4 sum = vec4(0.0);
 
   // blur in y (vertical)
   // take nine samples, with the distance blurSize between them
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y - 4.0*blurSize)) * 0.05;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y - 3.0*blurSize)) * 0.09;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y - 2.0*blurSize)) * 0.12;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y - blurSize)) * 0.15;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y + blurSize)) * 0.15;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y + 2.0*blurSize)) * 0.12;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y + 3.0*blurSize)) * 0.09;
   sum += texture2D(sceneTex, vec2(vTexCoord.x, vTexCoord.y + 4.0*blurSize)) * 0.05;
 
   gl_FragColor = sum;
}