#import "QCPatch.h"
#import "QCOpenGLContext.h"


#import "QCStringPort.h"

@interface SoftShadows : QCPatch
{


}


+ (BOOL)allowsSubpatches;


- (id)initWithIdentifier:(id)fp8;

- (id)setup:(QCOpenGLContext *)context;
- (void)cleanup:(QCOpenGLContext *)context;

- (void)enable:(QCOpenGLContext *)context;
- (void)disable:(QCOpenGLContext *)context;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end