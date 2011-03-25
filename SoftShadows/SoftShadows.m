/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 

 SoftShadows.m | Part of SoftShadows | Created 25/03/2011
 
 Copyright (c) 2010 Benjamin Blundell, www.section9.co.uk
 *** Section9 ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Section9 nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ***********************************************************************/


#import "SoftShadows.h"
#import "SoftShadowsUI.h"
#import "S9Math.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>
#import <SkankySDK/QCOpenGLContext.h>

#pragma mark statics

static void setTextureMatrix (CGLContextObj cgl_ctx ) {
	static double modelView[16];
	static double projection[16];
	
	// This is matrix transform every coordinate x,y,z
	// x = x* 0.5 + 0.5 
	// y = y* 0.5 + 0.5 
	// z = z* 0.5 + 0.5 
	// Moving from unit cube [-1,1] to [0,1]  
	const GLdouble bias[16] = {	
		0.5, 0.0, 0.0, 0.0, 
		0.0, 0.5, 0.0, 0.0,
		0.0, 0.0, 0.5, 0.0,
		0.5, 0.5, 0.5, 1.0};
	
	// Grab modelview and transformation matrices
	glGetDoublev(GL_MODELVIEW_MATRIX, modelView);
	glGetDoublev(GL_PROJECTION_MATRIX, projection);
	
	
	glMatrixMode(GL_TEXTURE);
	glActiveTextureARB(GL_TEXTURE7);
	
	glLoadIdentity();	
	glLoadMatrixd(bias);
	
	// concatating all matrice into one.
	glMultMatrixd (projection);
	glMultMatrixd (modelView);
	
	// Go back to normal matrix mode
	glMatrixMode(GL_MODELVIEW);
}


#pragma mark SoftShadows


@implementation SoftShadows

@synthesize mPhongShader;
@synthesize mFBO;

+(BOOL)isSafe {
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier {
	return YES;
}

// It appears that when we have a consumer within this patch, it will convert itself to a consumer! How odd?

+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier {
	return 1;
}

+(QCPatchTimeMode)timeModeWithIdentifier:(id)identifier {
	return 0;
}

-(id)initWithIdentifier:(id)identifier {
	if(self = [super initWithIdentifier:identifier]) {
		[[self userInfo] setObject:@"Soft Shadows" forKey:@"name"];
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SoftShadowsUI class];
}

-(BOOL)setup:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];

	if (mFBO == nil){
		NSRect bounds = NSMakeRect(0.0, 0.0, 640.0, 480.0);
		mFBO = [[S9FBO alloc] initWithContext:context andBounds:bounds];
	}
	
	// Load Shaders

	NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	
	mPhongShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"phong" forContext:cgl_ctx];
	if(mPhongShader == nil) {
		NSLog(@"Cannot compile GLSL shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled phong shader.\n");
	}
	
	mDepthShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"depthpcf" forContext:cgl_ctx];
	if(mDepthShader == nil) {
		NSLog(@"Cannot compile Depth Shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled Depth shader.\n");
	}
	
	
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context {
	[mPhongShader release];
	[mFBO release];
}

-(void)enable:(QCOpenGLContext*)context {

}

-(void)disable:(QCOpenGLContext*)context {
}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {

	// Allow Bypassing of this shader	
	if([inputBypass booleanValue]) {
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}
	
	
	// Bind Depth Shader and FBO For rendering the moments from the Light
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	
	[mFBO bindFBO];
	
	float omv[16];
	glGetFloatv(GL_MODELVIEW_MATRIX, omv);
	
	
	glUseProgramObjectARB([mDepthShader programObject]);

	float pos[3] = {[inputLightX doubleValue], [inputLightY doubleValue], [inputLightZ doubleValue]};
	float look[3] = {[inputLightLookX doubleValue], [inputLightLookY doubleValue], [inputLightLookZ doubleValue]};
	float up[3] = {0.0,1.0,0.0};
	
	glhLookAtf2(omv,pos,look,up);
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	
	glLoadMatrixf(omv);
	
	//glMatrixMode(GL_PROJECTION);
	//glLoadIdentity(); 
	//gluPerspective(55, mFBO.mBounds.size.width / mFBO.mBounds.size.height, 0.1, 500.0);
	
	//glMatrixMode(GL_MODELVIEW);
	//glLoadIdentity(); 
	
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	
	[self executeSubpatches:time arguments:arguments];
			
	
	setTextureMatrix(cgl_ctx);
	glPopMatrix();
	glDisable(GL_CULL_FACE);
	glUseProgramObjectARB(NULL);
	[mFBO unbindFBO];
	

	// set program vars
	//glUniform1iARB([mPhongShader getUniformLocation:"tex"], 0); 
	//glUniform1fARB([mPhongShader getUniformLocation:"shininess"], 128); 	
	
	// Now Render our Quad so that we can splat out a texture!
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [mFBO mTextureID]);
	
	
	glColor3f(1.0,1.0,1.0f);
	
	// Remember, with rectangle textures, we dont use 0-1
	
	GLsizei	width =  mFBO.mBounds.size.width;
	GLsizei height = mFBO.mBounds.size.height;

	
	glBegin(GL_QUADS);
	glTexCoord2f(0.0, 0.0);			glVertex3f(-1.0, -1.0, 0.0);
	glTexCoord2f(width, 0.0);		glVertex3f(1.0, -1.0, 0.0);
	glTexCoord2f(width, height);	glVertex3f(1.0, 1.0, 0.0);
	glTexCoord2f(0.0, height);		glVertex3f(-1.0, 1.0, 0.0);
	glEnd();
	
	glDisable(GL_TEXTURE_RECTANGLE_EXT);
	
	return YES;
}
@end
