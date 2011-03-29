#import "SoftShadowsPrincipal.h"
#import "SoftShadows.h"
#import "SofterShadows.h"

@implementation SoftShadowsPrincipal


+(void)registerNodesWithManager:(QCNodeManager*)manager {
	KIRegisterPatch(SoftShadows);
	KIRegisterPatch(SofterShadows); 
	//[manager registerNodeWithClass:[SoftShadows class]];
}


@end
