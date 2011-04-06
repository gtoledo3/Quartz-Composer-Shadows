/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 

 PCSSShadows.m | Part of SoftShadows | Created 25/03/2011
 
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


#import "PCSSShadows.h"
#import "PCSSShadowsUI.h"
#import "S9Math.h"
#import "S9Utils.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>
#import <OpenGL/gluMacro.h>
#import <SkankySDK/QCOpenGLContext.h>

#pragma mark PCSSShadows

@implementation PCSSShadows

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
		
		[inputOrtho setBooleanValue:FALSE];
		
		[inputNearLightPlane setDoubleValue: 0.1];
		[inputFarLightPlane setDoubleValue: 100.0];
		[inputFieldView setDoubleValue: 55.0];
		
		[inputMapSize setMaxDoubleValue:4096.0];
		[inputMapSize setMinDoubleValue:128.0];
		
		mFBOSize = 1024;
		
		[inputMapSize setDoubleValue: mFBOSize];
		
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [PCSSShadowsUI class];
}


-(void)resetFBOSize {
	
	float ti = (float)[inputMapSize doubleValue];
	
	int c = *(const int *) &ti;  // OR, for portability:  memcpy(&c, &v, sizeof c);
	c = (c >> 23) - 127;
	
	c = pow(2,c);
	
	if (mFBOSize != c){
		mFBOSize = c;
		NSLog(@"Resizing FBO to %i.\n",mFBOSize);
		[mShadowFBO generateNewTexture:mFBOSize];
		[mBlurHorizontalFBO generateNewTexture:mFBOSize];
		[mBlurVerticalFBO generateNewTexture:mFBOSize];
		[mDepthOnlyFBO generateNewTexture:mFBOSize];
	}
}


-(BOOL)setup:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];

	if (mShadowFBO == nil){
		
		mScreenFBO = [[S9FBO2D alloc] initWithContext:context andSize:2048 numTargets:1 accuracy:GL_RGB32F_ARB depthOnly:FALSE];
		
		mShadowFBO = [[S9FBO2D alloc] initWithContext:context andSize:1024 numTargets:1 accuracy:GL_RGB32F_ARB depthOnly:FALSE];
		
		mBlurHorizontalFBO = [[S9FBO2D alloc] initWithContext:context andSize:mFBOSize 
												   numTargets:1 accuracy:GL_RGB32F_ARB	depthOnly:FALSE]; 
		mBlurVerticalFBO = [[S9FBO2D alloc] initWithContext:context andSize:mFBOSize numTargets:1 
												   accuracy:GL_RGB32F_ARB depthOnly:FALSE]; 
	
		mDepthOnlyFBO =  [[S9FBO2D alloc] initWithContext:context andSize:1024 numTargets:1 accuracy:GL_RGB32F_ARB depthOnly:TRUE];
	}
	
	// Create Jitter Texture - Probably not needed after all?
	generateJitterTexture(&mJitterTexture, 128, 8, 8);
	
	// Load Shaders
	
	NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	

	mShadowShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"shadowpcss" forContext:cgl_ctx];
	if(mShadowShader == nil) { NSLog(@"Cannot compile Shadow Shader.\n"); return NO;}
		
	mBlurHorizontalShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"blurhoriz" forContext:cgl_ctx];
	if(mBlurHorizontalShader == nil) { NSLog(@"Cannot compile Blur Horizontal Shader.\n"); return NO; }
	
	mBlurVerticalShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"blurvertical" forContext:cgl_ctx];
	if(mBlurVerticalShader == nil) { NSLog(@"Cannot compile Blur Vertical Shader.\n"); return NO; }
	
	mCombineShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"shadowcombine" forContext:cgl_ctx];
	if(mCombineShader == nil) { NSLog(@"Cannot compile Shadow Combine Shader.\n"); return NO; }
	
	mLightShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"basiclight" forContext:cgl_ctx];
	if(mLightShader == nil) { NSLog(@"Cannot compile Basic Lighting Shader.\n"); return NO; }
	
	
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

	if (mShadowFBO == nil){
		[mShadowFBO release];
		[mBlurHorizontalFBO release];
		[mBlurVerticalFBO release];
		[mDepthOnlyFBO release];
	}
	

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


-(void) blurShadowMap:(QCOpenGLContext *)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	// Horizontal Blur
	
	[mBlurHorizontalFBO bindFBO];
	glUseProgramObjectARB([mBlurHorizontalShader programObject]);
	glUniform1iARB([mBlurHorizontalShader getUniformLocation:"RTScene"],0);
	glUniform1fARB([mBlurVerticalShader getUniformLocation:"blurSize"],(float)[inputBlurAmount doubleValue]);
	[self renderOrthoQuad:context withTex:[mShadowFBO getTextureAtTarget:0]];
	[mBlurHorizontalFBO unbindFBO];
	glUseProgramObjectARB(NULL);
	
	// Vertical Blur
	
	[mBlurVerticalFBO bindFBO];
	glUseProgramObjectARB([mBlurVerticalShader programObject]);
	glUniform1iARB([mBlurVerticalShader getUniformLocation:"RTScene"],0);
	glUniform1fARB([mBlurVerticalShader getUniformLocation:"blurSize"],(float)[inputBlurAmount doubleValue]);
	[self renderOrthoQuad:context withTex:[mBlurHorizontalFBO getTextureAtTarget:0]];
	
	glUseProgramObjectARB(NULL);
	[mBlurVerticalFBO unbindFBO];	
	
}


-(void) renderOrthoQuad:(QCOpenGLContext *)context withTex:(GLuint) tex {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(-1, 1, -1, 1, 0.0, 10.0);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glColor3f(1.0,1.0,1.0f);
	glBindTexture(GL_TEXTURE_2D, tex);
	
	glBegin(GL_QUADS);
	glTexCoord2f(0.0, 0.0);	glVertex3f(-1.0, -1.0, 0.0);
	glTexCoord2f(1.0, 0.0);	glVertex3f(1.0, -1.0, 0.0);
	glTexCoord2f(1.0, 1.0);	glVertex3f(1.0, 1.0, 0.0);
	glTexCoord2f(0.0, 1.0);	glVertex3f(-1.0, 1.0, 0.0);
	glEnd();
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
}

	
- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {

	// Allow Bypassing of this shader	
	if([inputBypass booleanValue]) {
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}

	
	CGLContextObj cgl_ctx = [context CGLContextObj];

	[self resetFBOSize];
	
	double shadowProjection[16];
	double shadowModelview[16];
	double cameraModelview[16];
	double finalMatrix[16];
	float finalFloatMatrix[16];
	
	// BIND TO DEPTH/SHADOWMAP
	// -----------------------
	glEnable(GL_TEXTURE_2D);
	
	[mDepthOnlyFBO bindFBO];	
	
	glPolygonOffset(1.0f, 1.0f);
	glEnable(GL_POLYGON_OFFSET_FILL);
	
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity(); 
	if ([inputOrtho booleanValue])
		glOrtho(-1, 1, -1, 1, [inputNearLightPlane doubleValue], [inputFarLightPlane doubleValue]);
	else 
		gluPerspective([inputFieldView doubleValue],1.0, [inputNearLightPlane doubleValue], [inputFarLightPlane doubleValue]);
	
	
	glGetDoublev(GL_PROJECTION_MATRIX, shadowProjection);
	
		
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	gluLookAt([inputLightX doubleValue], [inputLightY doubleValue], [inputLightZ doubleValue],
			  [inputLightLookX doubleValue], [inputLightLookY doubleValue], [inputLightLookZ doubleValue],
			  0.0,1.0,0.0);
	
	glGetDoublev(GL_MODELVIEW_MATRIX, shadowModelview);

	
	[self executeSubpatches:time arguments:arguments];
	

	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glDisable(GL_POLYGON_OFFSET_FILL);
	glCullFace(GL_BACK);
	//glDisable(GL_CULL_FACE);
	

	[mDepthOnlyFBO unbindFBO];
	
	
	// UNBIND DEPTH SHADER AND DRAW SHADOWS WITH SHADOW SHADER
	// -------------------------------------------------------
	
	[mShadowFBO bindFBO];
	
	glGetDoublev(GL_MODELVIEW_MATRIX, cameraModelview);
	
	setLightMatrix(finalMatrix, shadowProjection, shadowModelview, cameraModelview);
	floatMatrix(finalFloatMatrix,finalMatrix);
	
	glUseProgramObjectARB([mShadowShader programObject]);
	glUniform1iARB([mShadowShader getUniformLocation:"depthTexture"],1);
	glUniform1iARB([mShadowShader getUniformLocation:"rawDepth"],0);
	glUniform1iARB([mShadowShader getUniformLocation:"texMapSize"],mFBOSize);
	glUniform1fARB([mShadowShader getUniformLocation:"bottomLine"],(float)[inputBottomLine doubleValue]);
	glUniformMatrix4fv([mShadowShader getUniformLocation:"shadowTransMatrix"],16,FALSE,finalFloatMatrix);
	
	glUniform1iARB([mShadowShader getUniformLocation:"pcfSamples"],(int)[inputPCFSamples doubleValue]);
	glUniform1fARB([mShadowShader getUniformLocation:"lightSize"],(float)[inputLightSize doubleValue]);
	glUniform1fARB([mShadowShader getUniformLocation:"attenuation"],(float)[inputAttenuation doubleValue]);
	glUniform3fARB([mShadowShader getUniformLocation:"lightPosition"], [inputLightX doubleValue], [inputLightY doubleValue],[inputLightZ doubleValue]);
	glUniform3fARB([mShadowShader getUniformLocation:"lightLook"], [inputLightLookX doubleValue], [inputLightLookY doubleValue],[inputLightLookZ doubleValue]);
	

	// We need the actual values for the depth for PCSS so we cant use shadow2D functions with the COMPARE_R step :(
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, [mDepthOnlyFBO  mDepthID]);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_NONE); // No compare on our second step
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
	// Sadly we cant have different samples on the same texture, even if they are different units! ><
	
/*	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, [mDepthOnlyFBO  mDepthID]);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE);*/
	
	[self recallPatches:self context:context time:time arguments:arguments];
	
	glUseProgramObjectARB(NULL);
	[mShadowFBO unbindFBO];
	
	// BLUR THE SHADOW
	// ---------------
	
	if( [inputBlur booleanValue])
		[self blurShadowMap:context];
	
	// COMBINE BLUR AND SHADOW - THIRD PASS!! ><
	// -----------------------------------------
	
	// Could attempt to project the texture but this is easier and should be faster when we use multiple render targets.
	
	[mScreenFBO bindFBO];
	glUseProgramObjectARB([mLightShader programObject]);
	glUniform3fARB([mLightShader getUniformLocation:"lightPosition"], [inputLightX doubleValue], [inputLightY doubleValue],[inputLightZ doubleValue]);
	glUniform3fARB([mLightShader getUniformLocation:"lightLook"], [inputLightLookX doubleValue], [inputLightLookY doubleValue],[inputLightLookZ doubleValue]);
	
	[self recallPatches:self context:context time:time arguments:arguments];
	glUseProgramObjectARB(NULL);
	[mScreenFBO unbindFBO];

	
	glUseProgramObjectARB([mCombineShader programObject]);

	if ([inputBlur booleanValue]){
	
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D,[mBlurVerticalFBO getTextureAtTarget:0]);
		glUniform1iARB([mCombineShader getUniformLocation:"shadowTexture"],1);
	}
	else {
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D,[mShadowFBO getTextureAtTarget:0]);
		glUniform1iARB([mCombineShader getUniformLocation:"shadowTexture"],1);
	}

	
	glActiveTexture(GL_TEXTURE0);
	[self renderOrthoQuad:context withTex: [mScreenFBO getTextureAtTarget:0]];
	glUniform1iARB([mCombineShader getUniformLocation:"baseTexture"],0);

	glUseProgramObjectARB(NULL);
	glDisable(GL_CULL_FACE);
	
	// FINISHED - Draw Depth from the light view
	
	if( [inputDrawDepth booleanValue] ) { 
		glColor3f(0.0,0.0,0.0f);
		if ([inputBlur booleanValue]){
			[self renderOrthoQuad:context withTex: [mBlurVerticalFBO getTextureAtTarget:0]];
		}
		else {
			[self renderOrthoQuad:context withTex: [mShadowFBO getTextureAtTarget:0]];
		}

	}
	
	
	// Unbinds
	glActiveTexture(GL_TEXTURE1);
	glDisable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,0);
	glActiveTexture(GL_TEXTURE0);
	glDisable(GL_TEXTURE_2D);
	
	return YES;
}
@end
