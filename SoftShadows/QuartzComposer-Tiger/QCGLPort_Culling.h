#import <QCProtocols.h>
#import <QCIndexPort.h>

@interface QCGLPort_Culling : QCIndexPort <QCGLPort>
{
    unsigned char _enabled;
    int _mode;
}

- (id)initWithNode:(id)fp8 arguments:(NSDictionary*)args;
- (void)set:(CGLContextObj)context;
- (void)unset:(CGLContextObj)context;

@end
