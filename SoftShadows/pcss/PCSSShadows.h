/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 SoftShadows.h | Part of SoftShadows | Created 25/03/2011
 
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

#import "S9Shader.h"
#import "S9FBO.h"
#import "S9FBO2D.h"

@interface PCSSShadows: QCPatch
{
	QCNumberPort		*inputLightX;
	QCNumberPort		*inputLightY;
	QCNumberPort		*inputLightZ;
	
	QCNumberPort		*inputLightLookX;
	QCNumberPort		*inputLightLookY;
	QCNumberPort		*inputLightLookZ;
	
	QCNumberPort		*inputPCFSamples;
	QCNumberPort		*inputPCFScale;
	QCNumberPort		*inputBottomLine;
	
	QCNumberPort		*inputNearLightPlane;
	QCNumberPort		*inputFarLightPlane;
	QCNumberPort		*inputFieldView;
	
	QCBooleanPort		*inputBypass;
	QCBooleanPort		*inputOrtho;
	
	QCBooleanPort		*inputBlur;
	QCNumberPort		*inputBlurAmount;
	
	QCBooleanPort		*inputDrawDepth;
	QCNumberPort		*inputMapSize;
	

	S9Shader			*mDepthShader; // Specific to PCF Shadows
	S9Shader			*mShadowShader;
	S9Shader			*mShadowLinearShader;
	S9Shader			*mBlurHorizontalShader;
	S9Shader			*mBlurVerticalShader;
	S9Shader			*mCombineShader;
	
	S9FBO2D				*mFBO;
	S9FBO2D				*mDepthOnlyFBO;
	S9FBO2D				*mBlurHorizontalFBO;
	S9FBO2D				*mBlurVerticalFBO;
	
	GLuint				mJitterTexture;
	GLuint				mFBOSize;

	
}
+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;

-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;
-(void)recallPatches:(QCPatch*) patch context:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
-(void) blurShadowMap:(QCOpenGLContext *)context;
@end
