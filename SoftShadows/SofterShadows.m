/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 SofterShadows.m | Part of SoftShadows | Created 29/03/2011
 
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


#import "SofterShadows.h"
#import "S9Math.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>
#import <OpenGL/gluMacro.h>
#import <SkankySDK/QCOpenGLContext.h>

@implementation SofterShadows

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
		[[self userInfo] setObject:@"Softer Shadows" forKey:@"name"];
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SofterShadowsUI class];
}

-(BOOL)setup:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	if (mFBO == nil){
		// Fixed size, power of two as its Texture2D for simplicity
		mFBO = [[S9FBO2D alloc] initWithContext:context andSize:2048 depthOnly:FALSE];
		mBlurFBO = [[S9FBO2D alloc] initWithContext:context andSize:2048 depthOnly:FALSE]; 
	}
	
	// Load Shaders
	
	NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	
		
	mDepthShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"depthpcf" forContext:cgl_ctx];
	if(mDepthShader == nil) {
		NSLog(@"Cannot compile Depth Shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled Depth shader.\n");
	}
	
	
	mShadowShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"shadow" forContext:cgl_ctx];
	if(mShadowShader == nil) {
		NSLog(@"Cannot compile Shadow Shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled Shadow shader.\n");
	}
	
	mBlurShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"blur" forContext:cgl_ctx];
	if(mBlurShader == nil) {
		NSLog(@"Cannot compile Blur Shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled Blur shader.\n");
	}
	
	
	return YES;
}


-(void)logMatrix:(float*)matrix {
	NSLog(@"------------------\n");
	NSLog(@"%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f\n%f,%f,%f,%f\n",matrix[0],matrix[1],
		  matrix[2],matrix[3],matrix[4],matrix[5],matrix[6],
		  matrix[7],matrix[8],matrix[9],matrix[10],matrix[11],
		  matrix[12],matrix[13],matrix[14],matrix[15]);
}

-(void)cleanup:(QCOpenGLContext*)context {
	[mDepthShader release];
	[mShadowShader release];
	[mFBO release];
	[mBlurFBO release];
}

-(void)enable:(QCOpenGLContext*)context {	
}

-(void)disable:(QCOpenGLContext*)context {
}

// Recursive call to invalidate all patches and re-excute
// Likely to be SLOW!

-(void)recallPatches:(QCPatch*) patch context:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {
	
	NSArray *subpatches = [patch subpatches];
	NSEnumerator *e = [subpatches objectEnumerator];
	id object;
	
	while (object = [e nextObject]) {
		QCPatch *p = (QCPatch*)object;	
		if ([p _enabled]) {
			[p execute:context time:time arguments:arguments];
			[self recallPatches:p context:context time:time arguments:arguments];
		}
	}
}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {
	
	// Allow Bypassing of this shader	
	if([inputBypass booleanValue]) {
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	double shadowProjection[16];
	double shadowModelview[16];
	double finalMatrix[16];
	double cameraModelview[16];
	float finalFloatMatrix[16];
	
	// BIND TO DEPTH/SHADOWMAP
	// -----------------------
	
	glEnable(GL_TEXTURE_2D);
	
	[mFBO bindFBO];	
	
	glUseProgramObjectARB([mDepthShader programObject]);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity(); 
	gluPerspective(55,1.0, 0.1, 100.0);
	glGetDoublev(GL_PROJECTION_MATRIX, shadowProjection);
	
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	gluLookAt([inputLightX doubleValue], [inputLightY doubleValue], [inputLightZ doubleValue],
			  [inputLightLookX doubleValue], [inputLightLookY doubleValue], [inputLightLookZ doubleValue],
			  0.0,1.0,0.0);
	
	glGetDoublev(GL_MODELVIEW_MATRIX, shadowModelview);
	
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CW);
	glCullFace(GL_FRONT);
	
	[self executeSubpatches:time arguments:arguments];
	
	
	glDisable(GL_CULL_FACE);
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glUseProgramObjectARB(NULL);
	[mFBO unbindFBO];
	
	// UNBIND DEPTH AND APPLY BLUR 
	// ---------------------------
	
	[mBlurFBO bindFBO];
	
	glUseProgramObjectARB([mBlurShader programObject]);
	glUniform2fARB([mBlurShader getUniformLocation:"ScaleU"], 1.0/2048.0,  1.0/2048.0);
	glUniform1iARB([mBlurShader getUniformLocation:"textureSource"],0);
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(-1, 1, -1, 1, 0.0, 10.0);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glColor3f(1.0,1.0,1.0f);
	glBindTexture(GL_TEXTURE_2D, [mFBO mTextureID]);
	
	glBegin(GL_QUADS);
	glTexCoord2f(0.0, 0.0);		glVertex3f(-1.0, -1.0, 0.0);
	glTexCoord2f(1.0, 0.0);		glVertex3f(1.0, -1.0, 0.0);
	glTexCoord2f(1.0, 1.0);		glVertex3f(1.0, 1.0, 0.0);
	glTexCoord2f(0.0, 1.0);		glVertex3f(-1.0, 1.0, 0.0);
	glEnd();
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glUseProgramObjectARB(NULL);
	
	[mBlurFBO unbindFBO];
	
	
	// UNBIND BLUR SHADER AND DRAW WITH SHADOW SHADER
	// -----------------------------------------------
	
	glUseProgramObjectARB([mShadowShader programObject]);
	
	//multMatrix(finalMatrix, shadowProjection, shadowModelview);
	
	glGetDoublev(GL_MODELVIEW_MATRIX, cameraModelview);
	setLightMatrix(finalMatrix, shadowProjection, shadowModelview, cameraModelview);	
	
	floatMatrix(finalFloatMatrix,finalMatrix);
	
	glUniform1iARB([mShadowShader getUniformLocation:"ShadowMap"],0);
	glUniformMatrix4fv([mShadowShader getUniformLocation:"shadowTransMatrix"], 16, FALSE, finalFloatMatrix);
	
	
	// Activate the GL Light as its used in the shader
	
	/*	float lightPos[4] = { (float)[inputLightX doubleValue], 
	 (float)[inputLightY doubleValue], (float)[inputLightZ doubleValue], 0.0f};
	 
	 float spec[4] = {0.5f, 0.5f, 0.5f, 1.0f};
	 float dif[4] = {0.3f, 0.3f, 0.3f, 1.0f};
	 float amb[4] = {0.3f, 0.3f, 0.3f, 1.0f};
	 
	 glEnable(GL_LIGHT0);
	 glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
	 glLightfv(GL_LIGHT0, GL_SPECULAR, spec);
	 glLightfv(GL_LIGHT0, GL_DIFFUSE, dif);
	 glLightfv(GL_LIGHT0, GL_AMBIENT_AND_DIFFUSE,amb);*/
	
	// Bind Texture and draw our objects (but to which unit? Maybe it should be 1?)
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, [mBlurFBO mTextureID]);
	
	
	[self recallPatches:self context:context time:time arguments:arguments];
	
	
	glDisable(GL_CULL_FACE);
	
	glUseProgramObjectARB(NULL);
	
	//	glDisable(GL_LIGHT0);
	
	if( [inputDrawDepth booleanValue] ) {
		
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		glOrtho(-1.0, 1.0, -1.0, 1.0, 0.0, 10.0);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		
		glColor3f(1.0,1.0,1.0f);
		glBindTexture(GL_TEXTURE_2D, [mBlurFBO mTextureID]);
			
		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 0.0);		glVertex3f(-1.0, -1.0, 0.0);
		glTexCoord2f(1.0, 0.0);		glVertex3f(1.0, -1.0, 0.0);
		glTexCoord2f(1.0, 1.0);		glVertex3f(1.0, 1.0, 0.0);
		glTexCoord2f(0.0, 1.0);		glVertex3f(-1.0, 1.0, 0.0);
		glEnd();
		
		glPopMatrix();
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		
		
	}
	
	glDisable(GL_TEXTURE_2D);
	
	return YES;
}


@end
