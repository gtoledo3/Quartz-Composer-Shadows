#import <QCObjectPort.h>

@interface QCGLImagePort : QCObjectPort
{
}

+ (Class)baseClass;
- (Class)objectClass;
- (id)imageValue;
- (void)setImageValue:(id)fp8;

@end

@interface QCGLImagePort (Tooltip)
- (id)tooltipString;
- (id)tooltipExtensionView;
- (NSSize)tooltipExtensionViewSize:(id)fp8;
- (void)drawPortView:(id)fp8;
@end

@interface QCGLImagePort (NSImage)
- (BOOL)acceptValuesOfClass:(Class)class;
- (BOOL)setValue:(id)fp8;
@end

@interface QCGLImagePort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end

