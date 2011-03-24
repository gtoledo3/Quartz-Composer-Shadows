#import "ShaderTestPrincipal.h"
#import "ShaderTest.h"

@implementation ShaderTestPrincipal

+(void)registerNodesWithManager:(QCNodeManager*)manager
{
	//KIRegisterPatch(ShaderTest); 
	// each pattern checks to see if it's already registered.  Follow the pattern with additional patches.
	//if( [manager isNodeRegisteredWithName: NSStringFromClass([ShaderTest class])] == FALSE )
	[manager registerNodeWithClass:[ShaderTest class]];
}



@end
