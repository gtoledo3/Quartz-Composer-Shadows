#import "SoftShadows.h"
#import "SoftShadowsUI.h"



@implementation SoftShadows : QCPatch

+ (int)executionModeWithIdentifier:(id)fp8
{
	return 1;
}


+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}
+ (BOOL)allowsSubpatches
{
	return NO;
}

+ (int)timeModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)isSafe
{
	return YES;
}

/* If you don't want an inspector panel, simply comment out this function */
+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [SoftShadowsUI class];
}

- (id)initWithIdentifier:(id)fp8
{
	id z=[super initWithIdentifier:fp8];
	

	return z;
}


- (id)setup:(QCOpenGLContext *)context
{


	return context;
}
- (void)cleanup:(QCOpenGLContext *)context
{


}


- (void)enable:(QCOpenGLContext *)context
{


}
- (void)disable:(QCOpenGLContext *)context
{


}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	glColor4f(0.0,0.0,1.0,1.0);
	
    // Render the textured quad by mapping the texture coordinates to the vertices
    glBegin(GL_QUADS);
	
	glVertex3f(0.5, 0.5, 0); // upper right
	
	glVertex3f(-0.5, 0.5, 0); // upper left
	
	glVertex3f(-0.5, -0.5, 0); // lower left
	
	glVertex3f(0.5, -0.5, 0); // lower right
    glEnd();
	
	glPopMatrix();
	
	return YES;
}

@end
