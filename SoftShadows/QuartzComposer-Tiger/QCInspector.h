#import <QCPatch.h>

@interface QCInspector : NSObject
{
    NSView *view;
    QCPatch *_patch;
    void *unused2[4];
}

/* Returns the nib name for the Inspector panel UI */
+ (NSString*)viewNibName;
/* Returns the title of the Inspector Panel UI menu option */
+ (NSString*)viewTitle;
- (id)init;
- (void)didLoadNib;
- (QCPatch*)patch;
- (void)setupViewForPatch:(id)fp8;
- (void)resetView;
- (NSView*)view;

@end


