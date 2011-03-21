#import <QCPort.h>

@interface QCColorPort : QCPort
{
    float _red;
    float _green;
    float _blue;
    float _alpha;
}

- (float)redComponent;
- (float)greenComponent;
- (float)blueComponent;
- (float)alphaComponent;
- (void)getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha;
- (void)setRedComponent:(float)red;
- (void)setGreenComponent:(float)green;
- (void)setBlueComponent:(float)blue;
- (void)setAlphaComponent:(float)alpha;
- (void)setRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end

@interface QCColorPort (Override)
+ (Class)baseClass;
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (BOOL)canConnectToPort:(id)fp8;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
@end

@interface QCColorPort (NSColor)
- (id)value;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)class;
- (Class)valueClass;
@end

@interface QCColorPort (ValueEditing)
- (void)_doneColor:(id)fp8;
- (void)_windowWillClose:(id)fp8;
- (void)editValue:(id)fp8 view:(id)fp12;
@end

@interface QCColorPort (Tooltip)
- (id)tooltipString;
- (id)tooltipExtensionView;
- (NSSize)tooltipExtensionViewSize:(id)fp8;
- (void)drawPortView:(id)fp8;
@end

@interface QCColorPort (Primary)
- (void)_setPrimary:(CGLContextObj)fp8;
@end

@interface QCColorPort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end

