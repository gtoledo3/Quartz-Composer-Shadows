#import "QCProtocols.h"
#import "GFNodeManager.h"

@interface SoftShadowsPlugin : NSObject <GFPlugInRegistration>
+ (void)registerNodesWithManager:(GFNodeManager*)manager;
@end
