#import "SoftShadows.h"
#import "SoftShadowsUI.h"

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>


@implementation SoftShadows


+(BOOL)isSafe {
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier {
	return YES;
}

// It appears that when we have a consumer within this patch, it will convert itself to a consumer! How odd?

+(int)executionModeWithIdentifier:(id)identifier {
	return 1;
}

+(int)timeModeWithIdentifier:(id)identifier {
	return 0;
}

-(id)initWithIdentifier:(id)identifier {
	if(self = [super initWithIdentifier:identifier]) {
		[[self userInfo] setObject:@"Soft Shadows" forKey:@"name"];
	}
	return self;
}

/*+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SoftShadowsUI class];
}*/

-(BOOL)setup:(QCOpenGLContext*)context {
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context {
}

-(void)enable:(QCOpenGLContext*)context {

}

-(void)disable:(QCOpenGLContext*)context {
}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	//   double modifiedMatrix[16],t1,t2,t3;
	GLint oldMatrixMode;

	
	if([inputBypass booleanValue])
	{
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	
	GLfloat pos[] = {5.0, 5.0, 7.0, 1.0};
	GLfloat diff[] = {1.0, 1.0, 1.0, 1.0};
	
	glLightfv(GL_LIGHT0, GL_POSITION, pos);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diff);

	
	/*glGetIntegerv(GL_MATRIX_MODE,&oldMatrixMode);
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();*/

	glRotatef([inputXRotation doubleValue], 1., 0., 0.);
	glRotatef([inputYRotation doubleValue], 0., 1., 0.);
	glRotatef([inputZRotation doubleValue], 0., 0., 1.);
	
	[self executeSubpatches:time arguments:arguments];
	
	glBegin(GL_QUADS);
	glColor3f(1.0,0.0,0.0);
	glVertex3f(0.0,0.0,0.0);
	glVertex3f(1.0,0.0,0.0);
	glVertex3f(1.0,1.0,0.0);
	glVertex3f(0.0,1.0,0.0);
	glEnd();
	
	
	
	
/*	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();   
	glMatrixMode(oldMatrixMode);*/

	glDisable(GL_LIGHTING);
	
	return YES;
}
@end
