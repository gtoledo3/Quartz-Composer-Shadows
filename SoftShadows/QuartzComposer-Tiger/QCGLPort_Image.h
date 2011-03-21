#import <QCProtocols.h>
#import <QCGLImagePort.h>

@interface QCGLPort_Image : QCGLImagePort <QCGLPort>
{
}

- (void)set:(CGLContextObj)context;
- (void)unset:(CGLContextObj)context;
- (void)set:(CGLContextObj)context unit:(unsigned long)fp12 useTransformationMatrix:(BOOL)fp16;
- (void)unset:(CGLContextObj)context unit:(unsigned long)fp12;

@end

