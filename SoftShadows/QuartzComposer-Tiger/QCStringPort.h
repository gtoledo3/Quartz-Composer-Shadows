#import <QCPort.h>

@interface QCStringPort : QCPort
{
    NSString *_string;
}

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)string;

@end

@interface QCStringPort (Override)
+ (Class)baseClass;
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (void)dealloc;
- (id)value;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)class;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (Class)valueClass;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
@end

@interface QCStringPort (ValueEditing)
- (void)editValue:(id)fp8 view:(id)fp12;
@end

@interface QCStringPort (Tooltip)
- (id)tooltipString;
@end

@interface QCStringPort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end

