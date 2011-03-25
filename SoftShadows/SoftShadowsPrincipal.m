#import "SoftShadowsPrincipal.h"
#import "SoftShadows.h"

@implementation SoftShadowsPrincipal


+(void)registerNodesWithManager:(QCNodeManager*)manager {
	KIRegisterPatch(SoftShadows); 
	//[manager registerNodeWithClass:[SoftShadows class]];
}


@end
