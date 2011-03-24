#import "ShaderTest.h"
#import "ShaderTestUI.h"

@implementation ShaderTest
+(BOOL)isSafe {
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return YES;
}

+(int)executionModeWithIdentifier:(id)identifier {
	return 1;
}

+(int)timeModeWithIdentifier:(id)identifier {
	return 1;
}

-(id)initWithIdentifier:(id)identifier {
	if(self = [super initWithIdentifier:identifier]) {
		[[self userInfo] setObject:@"Shader Test" forKey:@"name"];
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [ShaderTestUI class];
}

-(BOOL)setup:(QCOpenGLContext*)context {
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context
{
	//[mFBO release];
}

-(void)enable:(QCOpenGLContext*)context {
	/*if( !mFBO) {
		CGLContextObj cgl_ctx = [context CGLContextObj];
		mFBO =[[S9FBO alloc] initWithContext: cgl_ctx];
	}*/
}

-(void)disable:(QCOpenGLContext*)context {

}

// http://kineme.net/forum/Discussion/Programming/Shadersinaplugin
// http://v002.info/?page_id=6

/*
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx 
				 width:(NSUInteger)pixelsWide 
				height:(NSUInteger)pixelsHigh 
				bounds:(NSRect)bounds 
			  texture1:(GLuint)texture1 
			  texture2:(GLuint)texture2 
			   colorIn:(CGFloat*)colorInComponents 
			  colorOut:(CGFloat*)colorOutComponents
			 threshold:(GLfloat)threshold 
				  blur:(GLfloat)blur 
				  fade:(GLfloat)fade 
				bypass:(GLboolean)bypass 
			 useImage2:(GLboolean)useImage2 
		   colorInvert:(GLboolean)colorInvert {
	
	GLsizei width = bounds.size.width,   height = bounds.size.height;
	
	// this must be called before any other FBO stuff can happen for 10.6
	[ShaderTest cachePreviousFBO:cgl_ctx];
	[ShaderTest setBounds:bounds context:cgl_ctx]; // this generates a new texture for us
	[ShaderTest attachFBO:cgl_ctx];
	
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);         
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture1);
	
	glActiveTexture(GL_TEXTURE1);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture2);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	
	GLfloat   colorIn[] = {colorInComponents[0], colorInComponents[1], colorInComponents[2], colorInComponents[3]};
	GLfloat   colorOut[] = {colorOutComponents[0], colorOutComponents[1], colorOutComponents[2], colorOutComponents[3]};
	
	// bind our shader program
	glUseProgramObjectARB([ShaderTest programObject]);
	
	// set program vars
	glUniform1iARB([ShaderTest getUniformLocation:"inputImage1"], 0); // load tex1 sampler to texture unit 0 
	glUniform1iARB([ShaderTest getUniformLocation:"inputImage2"], 1); // load tex1 sampler to texture unit 0 
	
	glUniform4fARB([ShaderTest getUniformLocation:"inputInColor"], [[colorIn objectAtIndex:0] floatValue], [[colorIn objectAtIndex:1] floatValue], [[colorIn objectAtIndex:2] floatValue], [[colorIn objectAtIndex:3] floatValue]); // pass in uniforms
	glUniform4fARB([ShaderTest getUniformLocation:"inputOutColor"], [[colorOut objectAtIndex:0] floatValue], [[colorOut objectAtIndex:1] floatValue], [[colorOut objectAtIndex:2] floatValue], [[colorOut objectAtIndex:3] floatValue]); // pass in uniforms
	glUniform1fARB([ShaderTest getUniformLocation:"inputThreshold"], threshold); // pass in uniforms
	glUniform1fARB([ShaderTest getUniformLocation:"inputBlur"], blur); // pass in uniforms
	glUniform1fARB([ShaderTest getUniformLocation:"inputFade"], fade); // pass in uniforms
	glUniform1iARB([ShaderTest getUniformLocation:"inputBypass"], bypass); // pass in uniforms
	glUniform1iARB([ShaderTest getUniformLocation:"inputUseImage2"], useImage2); // pass in uniforms
	glUniform1iARB([ShaderTest getUniformLocation:"inputInverseColor"], colorInvert); // pass in uniforms
	
	
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0);
	glVertex2f(0, 0);
	glTexCoord2f(0, pixelsHigh);
	glVertex2f(0, height);
	glTexCoord2f(pixelsWide, pixelsHigh);
	glVertex2f(width, height);
	glTexCoord2f(pixelsWide, 0);
	glVertex2f(width, 0);
	glEnd();      
	
	// disable shader program
	glUseProgramObjectARB(NULL);
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	glActiveTexture(GL_TEXTURE0);
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);   
	
	[ShaderTest detachFBO:cgl_ctx]; // pops out and resets cached FBO state from above.
	return [ShaderTest textureID];
	
	
}*/

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
//	[mFBO attachFBO: cgl_ctx];

	
	glMatrixMode(GL_MODELVIEW_MATRIX);
	glPushMatrix();	
	angle += 1.0;
	
	NSLog(@"Angle: %f", angle );
	
	glRotatef(angle,0,1,0);
	
	[self executeSubpatches:time arguments:arguments];
//	[mFBO detachFBO: cgl_ctx];
	
	glPopMatrix();
	
	return YES;
}

@end
