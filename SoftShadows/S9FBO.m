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

@implementation S9FBO

@synthesize fboID;
@synthesize textureID;
@synthesize bounds;

- (id) initWithContext:(CGLContextObj)ctx {
	GLenum error;

	if (self = [super init]) {
		
		context = ctx;
		CGLRetainContext(context);
		
		NSLog(@"FBO Context: %X\n", &context);
		
		bounds =  NSMakeRect(0.0, 0.0, 640.0, 480.0);
	
		glGenTextures(1, &textureID);	
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID);
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, self.bounds.size.width, self.bounds.size.height, 0, GL_RGBA, GL_FLOAT, NULL);
		
		glGenFramebuffersEXT(1, &fboID);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, textureID, 0);
		
	/*	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
		if(status != GL_FRAMEBUFFER_COMPLETE_EXT)
		{	
			glDeleteFramebuffersEXT(1, &fboID);
			glDeleteTextures(1, &textureID);
			
			NSLog(@"Cannot create FBO: %08X\n", status);
			
			if(error = glGetError())
				NSLog(@"OpenGL error %04X", error);
			
			[self release];
			return nil;
		}	*/

	}
	NSLog(@"Created an FBO\n");
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0); // Unbind
	
	return self;
	
}

- (void) setBounds:(NSRect)newBounds context:(CGLContextObj)cgl_ctx {

	[self willChangeValueForKey:@"bounds"];
	bounds = newBounds;
	[self didChangeValueForKey:@"bounds"];
	[self generateNewTexture:cgl_ctx];
}

- (void) attachFBO:(CGLContextObj)cgl_ctx {
	
	GLenum error;
		
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);
	
	GLsizei	width = self.bounds.size.width,	height = self.bounds.size.height;
	
	glViewport(0, 0,  width, height);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	
	glOrtho(0.0, width,  0.0,  height, -1, 1);		
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	if(error = glGetError())
        NSLog(@"OpenGL error %04X", error);
	
}

- (void) detachFBO:(CGLContextObj)cgl_ctx {
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	// restore states // assume this is balanced with above 
	glPopAttrib();
	glPopClientAttrib();

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);	
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, 0);
	glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, 0);
	
	glFlushRenderAPPLE();	
}

- (void) generateNewTexture:(CGLContextObj)cgl_ctx
{	
	//	glDeleteTextures(1, textureID);
	glGenTextures(1, &textureID);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID);
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA32F_ARB, self.bounds.size.width, self.bounds.size.height, 0, GL_RGBA, GL_FLOAT, NULL);

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, textureID, 0);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0); // Unbind
}

- (void)cleanupGL {
	CGLContextObj cgl_ctx = context;
	CGLLockContext(cgl_ctx);
	glDeleteFramebuffersEXT(1, &fboID);
	glDeleteTextures(1, &textureID);
	CGLUnlockContext(cgl_ctx);	
	CGLReleaseContext(context);
}

- (void) dealloc {
	[self cleanupGL];
	[super dealloc];
}

//- (void)finalize {
//	[self cleanupGL];
//	[super finalize];
//}


@end
