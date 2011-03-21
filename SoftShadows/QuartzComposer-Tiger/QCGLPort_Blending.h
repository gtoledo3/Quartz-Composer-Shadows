#import <QCProtocols.h>
#import <QCIndexPort.h>

@interface QCGLPort_Blending : QCIndexPort <QCGLPort>
{
    unsigned char _enabled;
    int _sourceFunction;
    int _destFunction;
}

- (id)initWithNode:(id)fp8 arguments:(NSDictionary*)args;
- (void)set:(CGLContextObj)context;
- (void)unset:(CGLContextObj)context;

@end

