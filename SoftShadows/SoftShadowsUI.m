#import "SoftShadowsUI.h"

@implementation SoftShadowsUI

/* This method returns the NIB file to use for the inspector panel */
+(NSString*)viewNibName
{
    return @"SoftShadowsUI";
}

/* This method specifies the title for the patch */
+(NSString*)viewTitle
{
    return @"SoftShadows";
}
@end