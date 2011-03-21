#import <QCPort.h>

@interface QCIndexPort : QCPort
{
    unsigned int _index;
    unsigned int _maxIndex;
}

- (unsigned int)indexValue;
- (void)setIndexValue:(unsigned int)index;
- (unsigned int)maxIndexValue;
- (void)setMaxIndexValue:(unsigned int)maxIndex;

@end

@interface QCIndexPort (Override)
+ (Class)baseClass;
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (id)value;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)class;
- (Class)valueClass;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
@end

@interface QCIndexPort (ValueEditing)
- (void)_setItemIndex:(id)fp8;
- (void)editValue:(id)fp8 view:(id)fp12;
@end

@interface QCIndexPort (Tooltip)
- (id)tooltipString;
@end

@interface QCIndexPort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end

