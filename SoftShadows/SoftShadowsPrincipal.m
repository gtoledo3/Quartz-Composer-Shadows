#import "SoftShadowsPrincipal.h"
#import "SoftShadows.h"

@implementation SoftShadowsPlugin
+ (void)registerNodesWithManager:(GFNodeManager*)manager
{
	// each pattern checks to see if it's already registered.  Follow the pattern with additional patches.
	if( [manager isNodeRegisteredWithName: NSStringFromClass([SoftShadows class])] == FALSE )
		[manager registerNodeWithClass:[SoftShadows class]];
}
@end
