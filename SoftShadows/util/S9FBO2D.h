/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 S9FBO2D.h | Part of SoftShadows | Created 28/03/2011
 
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

// Create, attach, detach and draw a basic framebuffer object
// http://www.gamedev.net/page/resources/_/reference/programming/opengl/opengl-frame-buffer-object-201-r2333
// Above link is good for Multiple Render Targets

@interface S9FBO2D : NSObject {
	QCOpenGLContext *mContext;
	GLuint			mFBOID;
	GLuint			mTextureID;
	GLuint			mDepthID;
	
	int		mSize;
	
	GLuint mColourTargets[10]; // Assume a Max of 10, naughty!
	GLenum mBuffers[10]; // Can actually be tested for. Its *probably* 4! :P
	
	
	GLuint mNumTargets;
	// Previous settings so we can go back
	
	GLint mPreviousFBO;
	GLint mPreviousReadFBO;
	GLint mPreviousDrawFBO;
	
	GLint mPreviousDrawBuffer;
	GLint mPreviousReadBuffer;
	GLuint	mAccuracy;
	
	
	
	BOOL mDepthOnly;
	BOOL mAllocated;
	
}

@property (readonly) GLuint	mFBOID;
@property (readonly) GLuint mDepthID;
@property (readwrite) int mSize;
@property (nonatomic,retain) QCOpenGLContext *mContext;

- (id) initWithContext:(QCOpenGLContext*)context andSize:(int) size numTargets:(int)ntargets accuracy:(GLuint) acc depthOnly:(BOOL)depth;


- (GLuint) getTextureAtTarget:(int)target;
- (void) bindFBO;
- (void) unbindFBO;
- (void) generateNewTexture:(GLuint) size;

-(void) pushFBO;
-(void) popFBO;

@end
