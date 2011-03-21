#import <QCProtocols.h>
#import <QCColorPort.h>

@interface QCGLPort_Color : QCColorPort <QCGLPort>
{
}

- (void)set:(CGLContextObj)context;
- (void)unset:(CGLContextObj)context;

@end

