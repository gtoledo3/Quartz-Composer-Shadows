/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 S9FBO.m | Part of ShaderTest | Created 23/03/2011
 
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


#import "S9FBO.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

@implementation S9FBO

@synthesize mFBOID;
@synthesize mTextureID;
@synthesize mBounds;
@synthesize mContext;


- (id) initWithContext:(QCOpenGLContext*)context andBounds:(NSRect)bounds {	
	
	if (self = [super init]) {
		
		CGLContextObj cgl_ctx = [context CGLContextObj];		
		
		CGLLockContext(cgl_ctx);

		mContext = context;
		[self pushFBO];
		
		mBounds = NSMakeRect(0.0, 0.0, bounds.size.width, bounds.size.height);
		
		GLsizei	width = bounds.size.width,	height = bounds.size.height;
		
		glGenTextures(1, &mTextureID);	
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, mTextureID);
		glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA32F_ARB, width, height, 0, GL_RGBA, GL_FLOAT, NULL);

		glGenFramebuffersEXT(1, &mFBOID);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mFBOID);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_EXT, mTextureID, 0);
		
		GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
		
		CGLUnlockContext(cgl_ctx);
		
		if(status != GL_FRAMEBUFFER_COMPLETE_EXT){
			glDeleteFramebuffersEXT(1, &mFBOID);
			glDeleteTextures(1, &mTextureID);
			[self release];
			NSLog(@"Failed to create an FBO: %04X\n", status);
			return nil;
		}
		[self popFBO];
	}
	
	NSLog(@"Created an FBO.\n");
	
	return self;
	
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
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, mFBOID);
	
	GLsizei	width = self.mBounds.size.width,	height = self.mBounds.size.height;
		
	glViewport(0, 0,  width, height);
	/*glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	
	glOrtho(0.0, width,  0.0,  height, -1, 1);		
		
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();*/
		
}


- (void) unbindFBO {
	CGLContextObj cgl_ctx = [mContext CGLContextObj];
	
/*	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();*/
	
	
	glPopAttrib();
	glPopClientAttrib();
	
	[self popFBO];
	
	glFlushRenderAPPLE();	
}

- (void) generateNewTexture {
}

@end
