/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 S9FBO2D.m | Part of SoftShadows | Created 28/03/2011
 
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

#import "S9FBO2D.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

@implementation S9FBO2D

@synthesize mFBOID;
@synthesize mDepthID;
@synthesize mContext;
@synthesize mSize;


- (id) initWithContext:(QCOpenGLContext*)context andSize:(int) size numTargets:(int)ntargets accuracy:(GLuint) acc mipMap:(BOOL) mm depthOnly:(BOOL)depth {
	
	if (self = [super init]) {
		mAllocated = FALSE;
		
		
		CGLContextObj cgl_ctx = [context CGLContextObj];		
		CGLLockContext(cgl_ctx);
		
		mContext = context;
		[self pushFBO];
	
		self.mSize = size;
		mDepthOnly = depth;
		mAccuracy = acc;
		mNumTargets = ntargets;
		mMipMaps = mm;
	
		
		glGenFramebuffersEXT(1, &mFBOID);
		
		[self generateNewTexture:size];
		
		GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
		
		CGLUnlockContext(cgl_ctx);
		
		if(status != GL_FRAMEBUFFER_COMPLETE_EXT){
			glDeleteFramebuffersEXT(1, &mFBOID);
			if (!mDepthOnly){
				for (int i=0; i< ntargets; i++){
					glDeleteTextures(1, &mColourTargets);
				}
			}
			glDeleteTextures(1, &mDepthID);
			[self release];
			NSLog(@"Failed to create an FBO: %04X\n", status);
			return nil;
		}
		[self popFBO];
	}
	
	NSLog(@"Created an FBO.\n");
	
	return self;
	
}
- (GLuint) getTextureAtTarget:(int)target {
	return mColourTargets[target];
}


// In QC, its a good idea to remember where to go back to

-(void) pushFBO{
	CGLContextObj cgl_ctx = [mContext CGLContextObj];	
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &mPreviousFBO);
	glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING_EXT, &mPreviousReadFBO);
	glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING_EXT, &mPreviousDrawFBO);
}

-(void) popFBO{
	CGLContextObj cgl_ctx = [mContext CGLContextObj];
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mPreviousFBO);	
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, mPreviousReadFBO);
	glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, mPreviousDrawFBO);
}

- (void) bindFBO{
	CGLContextObj cgl_ctx = [mContext CGLContextObj];
	
	// TODO - This is causing crashes!
//	[self pushFBO];
	
	
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mFBOID);

	GLsizei	width = self.mSize;	
	
	glDrawBuffers(mNumTargets,mBuffers);
	
	glViewport(0, 0,  width, width);
	
}

- (void) bindNoDraw {
	CGLContextObj cgl_ctx = [mContext CGLContextObj];
	
	// TODO - This is causing crashes!
	//	[self pushFBO];
	
	
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mFBOID);
	
	GLsizei	width = self.mSize;	
	
	glViewport(0, 0,  width, width);

}


- (void) unbindFBO {
	CGLContextObj cgl_ctx = [mContext CGLContextObj];

	glPopAttrib();
	glPopClientAttrib();
	
	[self popFBO];
	
	glFlushRenderAPPLE();	
}

- (void) generateNewTexture:(GLuint) size {
	CGLContextObj cgl_ctx = [mContext CGLContextObj];
	
	mSize = size;
	
	if (mAllocated){
		glDeleteTextures(mNumTargets, mColourTargets);
	}else {
		mAllocated = TRUE;
	}

	if (!mDepthOnly){
		
		glGenTextures(mNumTargets, mColourTargets);
	
		for (int i=0; i< mNumTargets; i++){
			
			glBindTexture(GL_TEXTURE_2D, mColourTargets[i]);
			glTexImage2D(GL_TEXTURE_2D, 0, mAccuracy, size, size, 0, GL_RGBA, GL_UNSIGNED_INT, NULL);
			
			if(mMipMaps) {
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
				glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
				GLfloat largest_supported_anisotropy;
				glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &largest_supported_anisotropy);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, largest_supported_anisotropy);
				
			}
			else {
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
				
			}
				
			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP );
			glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP );
						
			mBuffers[i] = GL_COLOR_ATTACHMENT0_EXT + i;
		}
		
	}
	
	glGenTextures(1, &mDepthID);
	glBindTexture(GL_TEXTURE_2D, mDepthID);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32, size, size, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	// Linear should give better results on NVidia but apparently we can get that from using shadow2DProj as well?
	
	/*if (mDepthOnly){
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE );
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL);
		glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE, GL_INTENSITY); 	
	}*/
	
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mFBOID);
	
	if (!mDepthOnly){
		for (int i=0; i< mNumTargets; i++){
			glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT + i, GL_TEXTURE_2D, mColourTargets[i], 0);
		}
	}
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, mDepthID, 0);
	
	if (mDepthOnly){
		glDrawBuffer(GL_NONE);
		glReadBuffer(GL_NONE);
	}
	
	
}

@end
