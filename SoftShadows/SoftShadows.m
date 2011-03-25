/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 

 SoftShadows.m | Part of SoftShadows | Created 25/03/2011
 
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


#import "SoftShadows.h"
#import "SoftShadowsUI.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>


@implementation SoftShadows

@synthesize mPhongShader;

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
	}
	return self;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SoftShadowsUI class];
}

-(BOOL)setup:(QCOpenGLContext*)context {
	
	// Load Shaders
	CGLContextObj cgl_ctx = [context CGLContextObj];

	NSBundle *pluginBundle =[NSBundle bundleForClass:[self class]];	
	mPhongShader = [[S9Shader alloc] initWithShadersInBundle:pluginBundle withName: @"phong" forContext:cgl_ctx];
	if(mPhongShader == nil) {
		NSLog(@"Cannot compile GLSL shader.\n");
		return NO;
	}
	else {
		NSLog(@"Compiled phong shader.\n");
	}

	
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context {
	[mPhongShader release];
}

-(void)enable:(QCOpenGLContext*)context {

}

-(void)disable:(QCOpenGLContext*)context {
}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments {

	if([inputBypass booleanValue]) {
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}
	
	// Bind Shader
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glUseProgramObjectARB([mPhongShader programObject]);
	
	// set program vars
	glUniform1iARB([mPhongShader getUniformLocation:"tex"], 0); 
	glUniform1fARB([mPhongShader getUniformLocation:"shininess"], 128); 	
	

	[self executeSubpatches:time arguments:arguments];

	glUseProgramObjectARB(NULL);
	
	return YES;
}
@end
