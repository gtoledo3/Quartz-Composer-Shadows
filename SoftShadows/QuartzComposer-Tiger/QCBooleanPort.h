#import <QCPort.h>
#import <QCProxyPort.h>

@interface QCBooleanPort : QCPort
{
    BOOL _value;
}

- (BOOL)booleanValue;
- (void)setBooleanValue:(BOOL)value;

@end

@interface QCBooleanPort (Override)
+ (Class)baseClass;
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (id)value;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)fp8;
- (Class)valueClass;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
@end

@interface QCBooleanPort (ValueEditing)
- (void)_setTrue:(id)fp8;
- (void)_setFalse:(id)fp8;
- (void)editValue:(id)fp8 view:(id)fp12;
@end

@interface QCBooleanPort (Tooltip)
- (id)tooltipString;
@end

@interface QCBooleanPort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end
