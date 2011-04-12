/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 DepthofField.m | Part of DepthofField | Created 11/04/2011
 
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


#import "DepthofField.h"


@implementation DepthofField


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
		[[self userInfo] setObject:@"Depth of Field" forKey:@"name"];
		
		// TODO - If not already set, set these :P
		// TODO set max and mins
		
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [DepthofFieldUI class];
}


-(void) glError:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	GLenum err = glGetError();
	while (err != GL_NO_ERROR) {
		NSLog(@"glError: %s caught!\n", (char *)gluErrorString(err));
		err = glGetError();
	}
}

-(BOOL)setup:(QCOpenGLContext*)context {
	
	CGLContextObj cgl_ctx = [context CGLContextObj];

}


-(void)cleanup:(QCOpenGLContext*)context {
}

-(void)enable:(QCOpenGLContext*)context {	
}

-(void)disable:(QCOpenGLContext*)context {
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


}	


@end
