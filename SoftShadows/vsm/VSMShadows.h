/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 SofterShadows.h | Part of SoftShadows | Created 29/03/2011
 
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

#import <Cocoa/Cocoa.h>
#import "S9Shader.h"
#import "S9FBO2D.h"
#import "VSMShadowsUI.h"

@interface VSMShadows : QCPatch {
	QCNumberPort		*inputLightX;
	QCNumberPort		*inputLightY;
	QCNumberPort		*inputLightZ;
	
	QCNumberPort		*inputLightLookX;
	QCNumberPort		*inputLightLookY;
	QCNumberPort		*inputLightLookZ;
	
	QCNumberPort		*inputNearLightPlane;
	QCNumberPort		*inputFarLightPlane;
	QCNumberPort		*inputFieldView;
	QCNumberPort		*inputAmbient;
	QCNumberPort		*inputLightAttenuation;
	QCNumberPort		*inputFilterSize;
	
	QCBooleanPort		*inputBlur;
	QCNumberPort		*inputBlurAmount;
	QCNumberPort		*inputBlurDepthAmount;
	QCBooleanPort		*inputBypass;
	QCBooleanPort		*inputDrawDepth;
	QCBooleanPort		*inputOrtho;
	
	
	QCNumberPort		*inputVariance;
	QCNumberPort		*inputMapSize;
	
	S9Shader			*mDepthShader;
	S9Shader			*mShadowShader;
	S9Shader			*mBlurShader;
	S9Shader			*mBlurHorizontalShader;
	S9Shader			*mBlurVerticalShader;
	S9Shader			*mSummedTableShader;
	S9Shader			*mSummedTableVShader;
	S9Shader			*mSummedReverseShader;
	
	S9FBO2D				*mFBO;
	S9FBO2D				*mSummedFBO;
	
	// TODO - Change to use two render targets rather than two FBOs
	S9FBO2D				*mBlurHorizontalFBO;
	S9FBO2D				*mBlurVerticalFBO;
	
	GLuint				mFBOSize;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;

-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;
-(void)recallPatches:(QCPatch*) patch context:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
-(void)blurShadowMap:(QCOpenGLContext*)context;
-(void) renderOrthoQuad:(QCOpenGLContext *)context withTex:(GLuint)tex;
-(void) generateSummedTables:(QCOpenGLContext *)context withTex:(GLuint) tex;

@end
