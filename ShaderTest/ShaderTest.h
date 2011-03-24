
// http://kineme.net/forum/Discussion/Programming/Shadersinaplugin
// http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Conceptual/QuartzComposer_Patch_PlugIn_ProgGuide/WritingConsumerPatches/WritingConsumerPatches.html#//apple_ref/doc/uid/TP40004787-CH5-SW1
// http://kineme.net/forum/Discussion/Programming/ShaderMeshSubpatchesSkankyConsumerPatch#comment-19737

#import "S9FBO.h"

@interface ShaderTest : QCPatch
{
	S9FBO *mFBO;
	float angle;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
+(int)executionModeWithIdentifier:(id)identifier;
+(int)timeModeWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)setup:(QCOpenGLContext*)context;
-(void)cleanup:(QCOpenGLContext*)context;
-(void)enable:(QCOpenGLContext*)context;
-(void)disable:(QCOpenGLContext*)context;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
