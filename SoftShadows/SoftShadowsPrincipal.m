#import "SoftShadowsPrincipal.h"
#import "PCSSShadows.h"

@implementation SoftShadowsPrincipal


+(void)registerNodesWithManager:(QCNodeManager*)manager {
	KIRegisterPatch(PCSSShadows); 
	//[manager registerNodeWithClass:[SoftShadows class]];
}


@end
