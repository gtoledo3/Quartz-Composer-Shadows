#import <QCProtocols.h>
#import <QCIndexPort.h>

@interface QCGLPort_ZBuffer : QCIndexPort <QCGLPort>
{
    unsigned char _enabled;
    int _function;
    int _mask;
}

- (id)initWithNode:(id)fp8 arguments:(NSDictionary*)args;
- (void)set:(CGLContextObj)context;
- (void)unset:(CGLContextObj)context;

@end

