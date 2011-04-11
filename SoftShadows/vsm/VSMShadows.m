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


// An implemetation of VSM Shadowing
// http://http.developer.nvidia.com/GPUGems3/gpugems3_ch08.html
// http://www.punkuser.net/vsm/
// http://www.fabiensanglard.net/shadowmappingVSM/index.php
// http://www.punkuser.net/vsm/vsm_paper.pdf
// http://forum.beyond3d.com/showthread.php?t=38165
// http://www.cgl.uwaterloo.ca/poster/andrew_I3D07.pdf


// TODO - Antialias FBOs
//		- Test mipmapping of the FBO textures


#import "VSMShadows.h"
#import "S9Math.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>
#import <OpenGL/gluMacro.h>
#import <SkankySDK/QCOpenGLContext.h>

@implementation VSMShadows

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
		[[self userInfo] setObject:@"VSM Shadows" forKey:@"name"];
		
		// TODO - If not already set, set these :P
		// TODO set max and mins
		
		[inputVariance setDoubleValue: 0.00002];
		[inputOrtho setBooleanValue:FALSE];
		
		[inputNearLightPlane setDoubleValue: 0.1];
		[inputFarLightPlane setDoubleValue: 100.0];
		[inputFieldView setDoubleValue: 55.0];
		
		[inputMapSize setMaxDoubleValue:4096.0];
		[inputMapSize setMinDoubleValue:128.0];
		
		mFBOSize = 2048;
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [VSMShadowsUI class];
}


-(void) glError:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	GLenum err = glGetError();
	while (err != GL_NO_ERROR) {
		NSLog(@"glError: %s caught!\n", (char *)gluErrorString(err));
		err = glGetError();
	}
}


-(void)resetFBOSize {
	
	float ti = (float)[inputMapSize doubleValue];
	
	int c = *(const int *) &ti;  // OR, for portability:  memcpy(&c, &v, sizeof c);
	c = (c >> 23) - 127;
	
	c = pow(2,c);
	
	if (mFBOSize != c){
		mFBOSize = c;
		NSLog(@"Resizing FBO to %i.\n",mFBOSize);
		[mFBO generateNewTexture:mFBOSize];
		[mBlurHorizontalFBO generateNewTexture:mFBOSize];
		[mBlurVerticalFBO generateNewTexture:mFBOSize];
		
	}
}

-(BOOL)setup:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	if (mFBO == nil){
		// Fixed size, power of two as its Texture2D for simplicity
		mFBO = [[S9FBO2D alloc] initWithContext:context andSize:mFBOSize numTargets:1 accuracy:GL_RGB32F_ARB  
									  depthOnly:FALSE];

		mBlurHorizontalFBO = [[S9FBO2D alloc] initWithContext:context andSize:mFBOSize 
												   numTargets:1 accuracy:GL_RGB32F_ARB	depthOnly:FALSE]; 
		mBlurVerticalFBO = [[S9FBO2D alloc] initWithContext:context andSize:mFBOSize numTargets:1 
												   accuracy:GL_RGB32F_ARB depthOnly:FALSE]; 
	}
	
	// Load Shaders
	
	NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	
		
	mDepthShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"depth" forContext:cgl_ctx];
	if(mDepthShader == nil) { NSLog(@"Cannot compile Depth Shader.\n"); return NO; }
	else NSLog(@"Compiled Depth shader.\n");
	
	mShadowShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"shadowvsm" forContext:cgl_ctx];
	if(mShadowShader == nil) { NSLog(@"Cannot compile Shadow Shader.\n"); return NO; }
	else NSLog(@"Compiled Shadow shader.\n"); 
	
	mBlurHorizontalShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"blurhoriz" forContext:cgl_ctx];
	if(mBlurHorizontalShader == nil) { NSLog(@"Cannot compile Blur Horizontal Shader.\n"); return NO; }
	else NSLog(@"Compiled Blur Horizontal shader.\n");
	
	mBlurVerticalShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"blurvertical" forContext:cgl_ctx];
	if(mBlurVerticalShader == nil) { NSLog(@"Cannot compile Blur Vertical Shader.\n"); return NO; }
	else NSLog(@"Compiled Blur Vertical shader.\n");
	
	
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
	[mBlurHorizontalShader release];
	[mBlurVerticalShader release];
	[mFBO release];
	[mBlurHorizontalFBO release];
	[mBlurVerticalFBO release];
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

-(void) blurShadowMap:(QCOpenGLContext *)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	// Horizontal Blur
	
	[mBlurHorizontalFBO bindFBO];
	glUseProgramObjectARB([mBlurHorizontalShader programObject]);
	glUniform1iARB([mBlurHorizontalShader getUniformLocation:"RTScene"],0);
	glUniform1fARB([mBlurVerticalShader getUniformLocation:"blurSize"],(float)[inputBlurDepthAmount doubleValue]);
	[self renderOrthoQuad:context withTex:[mFBO getTextureAtTarget:0]];
	[mBlurHorizontalFBO unbindFBO];
	glUseProgramObjectARB(NULL);
	
	// Vertical Blur
	
	[mBlurVerticalFBO bindFBO];
	glUseProgramObjectARB([mBlurVerticalShader programObject]);
	glUniform1iARB([mBlurVerticalShader getUniformLocation:"RTScene"],0);
	glUniform1fARB([mBlurVerticalShader getUniformLocation:"blurSize"],(float)[inputBlurDepthAmount doubleValue]);
	[self renderOrthoQuad:context withTex:[mBlurHorizontalFBO getTextureAtTarget:0]];
	
	glUseProgramObjectARB(NULL);
	[mBlurVerticalFBO unbindFBO];	

}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {
	
	// Allow Bypassing of this shader	
	if([inputBypass booleanValue]) {
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}
	
	[self resetFBOSize];
	
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
	glUniform1fARB([mDepthShader getUniformLocation:"far"],(float)[inputFarLightPlane doubleValue]);
	
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity(); 
	if ([inputOrtho booleanValue])
		glOrtho(-1.0, 1.0, -1.0, 1.0, [inputNearLightPlane doubleValue], [inputFarLightPlane doubleValue]);
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
	

//	glPolygonOffset(1.0f, 1.0f);
//	glEnable(GL_POLYGON_OFFSET_FILL);
	
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CW);
	glCullFace(GL_FRONT);
	
	[self recallPatches:self context:context time:time arguments:arguments];
	
	
//	glDisable(GL_POLYGON_OFFSET_FILL);
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glUseProgramObjectARB(NULL);
	[mFBO unbindFBO];
	
	// UNBIND DEPTH AND APPLY BLUR 
	// ---------------------------
	
	if ([inputBlur booleanValue]){
		[self blurShadowMap:context];
	}
	
	// UNBIND BLUR SHADER AND DRAW WITH SHADOW SHADER
	// -----------------------------------------------

	
	glUseProgramObjectARB([mShadowShader programObject]);
	
	//multMatrix(finalMatrix, shadowProjection, shadowModelview);
	
	glGetDoublev(GL_MODELVIEW_MATRIX, cameraModelview);
	setLightMatrixNoBias(finalMatrix, shadowProjection, shadowModelview, cameraModelview);	
	
	floatMatrix(finalFloatMatrix,finalMatrix);
	
	glUniform1iARB([mShadowShader getUniformLocation:"ShadowMap"],0);
	glUniformMatrix4fv([mShadowShader getUniformLocation:"shadowTransMatrix"], 16, FALSE, finalFloatMatrix);
	glUniform1fARB([mShadowShader getUniformLocation:"minVariance"], (float)[inputVariance doubleValue]);
	glUniform1fARB([mShadowShader getUniformLocation:"blurAmount"], (float)[inputBlurAmount doubleValue]);
	glUniform1fARB([mShadowShader getUniformLocation:"ambientLevel"], (float)[inputAmbient doubleValue]);
	glUniform1fARB([mShadowShader getUniformLocation:"lightAttenuation"], (float)[inputLightAttenuation doubleValue]);
	glUniform4fARB([mShadowShader getUniformLocation:"lightPosition"],
				   (float)[inputLightX doubleValue], (float)[inputLightY doubleValue], (float)[inputLightZ doubleValue], 0.0);
	glUniform4fARB([mShadowShader getUniformLocation:"lightLook"],
				   (float)[inputLightLookX doubleValue], (float)[inputLightLookY doubleValue], (float)[inputLightLookZ doubleValue], 0.0);
	
	
	if([inputBlur booleanValue])
		glBindTexture(GL_TEXTURE_2D, [mBlurVerticalFBO getTextureAtTarget:0]);
	else 
		glBindTexture(GL_TEXTURE_2D, [mFBO getTextureAtTarget:0]);
	
	glCullFace(GL_BACK);
	
	[self executeSubpatches:time arguments:arguments];

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
		if([inputBlur booleanValue])
			glBindTexture(GL_TEXTURE_2D, [mBlurVerticalFBO getTextureAtTarget:0]);
		else 
			glBindTexture(GL_TEXTURE_2D, [mFBO getTextureAtTarget:0]);
			
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
	
	[self glError:context];
	
	return YES;
}


@end
