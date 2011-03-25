/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
 S9Shader.m | Part of SoftShadows | Created 25/03/2011
 
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


// Adapted from the excellent Vade's v002 Shader - http://vade.info

#import "S9Shader.h"
#import <OpenGL/CGLMacro.h>

#pragma mark -- Compiling shaders & linking a program object --

static GLhandleARB LoadShader(GLenum theShaderType, 
							  const GLcharARB **theShader, 
							  GLint *theShaderCompiled,
							  CGLContextObj context) 
{
	CGLContextObj cgl_ctx = context;
	GLhandleARB shaderObject = NULL;
	
	if( theShader != NULL ) 
	{
		GLint infoLogLength = 0;
		
		shaderObject = glCreateShaderObjectARB(theShaderType);
		
		glShaderSourceARB(shaderObject, 1, theShader, NULL);
		glCompileShaderARB(shaderObject);
		
		glGetObjectParameterivARB(shaderObject, 
								  GL_OBJECT_INFO_LOG_LENGTH_ARB, 
								  &infoLogLength);
		
		if( infoLogLength > 0 )  {
			GLcharARB *infoLog = (GLcharARB *)malloc(infoLogLength);
			
			if( infoLog != NULL )
			{
				glGetInfoLogARB(shaderObject, 
								infoLogLength, 
								&infoLogLength, 
								infoLog);
				
				NSLog(@">> Shader compile log:\n%s\n", infoLog);
				
				free(infoLog);
			}
		}
		
		glGetObjectParameterivARB(shaderObject, 
								  GL_OBJECT_COMPILE_STATUS_ARB, 
								  theShaderCompiled);
		
		if( *theShaderCompiled == 0 ) {
			NSLog(@">> Failed to compile shader %s\n", theShader);
		}
	}
	else  {
		*theShaderCompiled = 1;
	}	
	return shaderObject;
} 

//---------------------------------------------------------------------------------

static void LinkProgram(GLhandleARB programObject, 
						GLint *theProgramLinked,
						CGLContextObj context) 
{
	CGLContextObj cgl_ctx = context;
	
	GLint  infoLogLength = 0;
	
	glLinkProgramARB(programObject);
	
	glGetObjectParameterivARB(programObject, 
							  GL_OBJECT_INFO_LOG_LENGTH_ARB, 
							  &infoLogLength);
	
	if( infoLogLength >  0 ) {
		GLcharARB *infoLog = (GLcharARB *)malloc(infoLogLength);
		
		if( infoLog != NULL) {
			glGetInfoLogARB(programObject, 
							infoLogLength, 
							&infoLogLength, 
							infoLog);
			
			NSLog(@">> Program link log:\n%s\n", infoLog);
			
			free(infoLog);
		}
	}
	
	glGetObjectParameterivARB(programObject, 
							  GL_OBJECT_LINK_STATUS_ARB, 
							  theProgramLinked);
	
	if( *theProgramLinked == 0 ) {
		NSLog(@">> Failed to link program 0x%lx\n", (GLubyte *)&programObject);
	}
}


@implementation S9Shader

#pragma mark -- Get shaders from resource --


- (GLcharARB *) getShaderSourceFromResource:(NSString *)theShaderResourceName 
								  extension:(NSString *)theExtension
{	
	NSString  *shaderTempSource = [bundleToLoadFrom pathForResource:theShaderResourceName 
															 ofType:theExtension];	
	GLcharARB *shaderSource = NULL;
	shaderTempSource = [NSString stringWithContentsOfFile:shaderTempSource usedEncoding:nil error:nil];
	shaderSource = (GLcharARB *)[shaderTempSource cStringUsingEncoding:NSASCIIStringEncoding];
	
	return  shaderSource;
}



- (void) getFragmentShaderSourceFromResource:(NSString *)theFragmentShaderResourceName {
	fragmentShaderSource = [self getShaderSourceFromResource:theFragmentShaderResourceName 
												   extension:@"frag" ];
}


- (void) getVertexShaderSourceFromResource:(NSString *)theVertexShaderResourceName {
	vertexShaderSource = [self getShaderSourceFromResource:theVertexShaderResourceName 
												 extension:@"vert" ];
}

- (GLhandleARB) loadShader:(GLenum)theShaderType shaderSource:(const GLcharARB **)theShaderSource {
	CGLContextObj cgl_ctx = shaderContext;
	
	GLint       shaderCompiled = 0;
	GLhandleARB shaderHandle   = LoadShader(theShaderType, 
											theShaderSource, 
											&shaderCompiled, shaderContext);
	
	if( !shaderCompiled )  {
		if( shaderHandle ) {
			glDeleteObjectARB(shaderHandle);
			shaderHandle = NULL;
		}
	}
	
	return shaderHandle;
}


- (BOOL) newProgramObject:(GLhandleARB)theVertexShader  fragmentShaderHandle:(GLhandleARB)theFragmentShader {
	
	CGLContextObj cgl_ctx = shaderContext;
	GLint programLinked = 0;
	
	// Create a program object and link both shaders
	
	programObject = glCreateProgramObjectARB();
	
	glAttachObjectARB(programObject, theVertexShader);
	glDeleteObjectARB(theVertexShader);
	
	glAttachObjectARB(programObject, theFragmentShader);
	glDeleteObjectARB(theFragmentShader);
	
	LinkProgram(programObject, &programLinked, cgl_ctx);
	
	if( !programLinked )  {
		glDeleteObjectARB(programObject);
		programObject = NULL;
		return NO;
	}
	
	return YES;
}

- (BOOL) setProgramObject {	
	BOOL  programObjectSet = NO;
	
	// Load and compile both shaders
	
	GLhandleARB vertexShader = [self loadShader:GL_VERTEX_SHADER_ARB 
								   shaderSource:&vertexShaderSource];
	
	// Ensure vertex shader compiled
	
	if( vertexShader != NULL ) {
		GLhandleARB fragmentShader = [self loadShader:GL_FRAGMENT_SHADER_ARB 
										 shaderSource:&fragmentShaderSource];
		
		// Ensure fragment shader compiled
		
		if( fragmentShader != NULL ) {
			programObjectSet = [self newProgramObject:vertexShader fragmentShaderHandle:fragmentShader];
		} 
	}
	
	return  programObjectSet;
}


#pragma mark -- Designated Initializer --

- (id) initWithShadersInBundle:(NSBundle*)bundle withName:(NSString *)theShadersName forContext:(CGLContextObj) context
{
	if(self = [super init])
	{
		bundleToLoadFrom = [bundle retain];
		shaderContext = context; 
		
		BOOL  loadedShaders = NO;
		
		// Load vertex and fragment shader
		
		[self getVertexShaderSourceFromResource:theShadersName];
		
		if( vertexShaderSource != NULL )
		{
			[self getFragmentShaderSourceFromResource:theShadersName];
			
			if( fragmentShaderSource != NULL )
			{
				loadedShaders = [self setProgramObject];
				
				if( !loadedShaders)
				{
					NSLog(@">> WARNING: Failed to load GLSL \"%@\" fragment & vertex shaders!\n", 
						  theShadersName);
				}
			}
		}
	}
	return self;
}

- (id) initWithShadersInAppBundle:(NSString *)theShadersName forContext:(CGLContextObj)context; {
	return [self initWithShadersInBundle:[NSBundle mainBundle] withName:theShadersName forContext:context];
}


#pragma mark -- Deallocating Resources --


- (void) finalize {

	CGLContextObj cgl_ctx = shaderContext;
	
	if( programObject ) {
		glDeleteObjectARB(programObject);
		programObject = NULL;
	}
	
	[super finalize];
}

- (void) dealloc {
	// Delete OpenGL resources
	CGLContextObj cgl_ctx = shaderContext;
	
	if( programObject ) {
		glDeleteObjectARB(programObject);
		programObject = NULL;
	}
	
	[bundleToLoadFrom release];	
	[super dealloc];
}


#pragma mark -- Accessors --


- (GLhandleARB) programObject {
	return  programObject;
}


#pragma mark -- Utilities --


- (GLint) getUniformLocation:(const GLcharARB *)theUniformName {
	CGLContextObj cgl_ctx = shaderContext;
	
	GLint uniformLoacation = glGetUniformLocationARB(programObject, 
													 theUniformName);
	
	if( uniformLoacation == -1 )  {
		NSLog( @">> WARNING: No such uniform named \"%s\"\n", theUniformName );
	}
	
	return uniformLoacation;
}


@end
