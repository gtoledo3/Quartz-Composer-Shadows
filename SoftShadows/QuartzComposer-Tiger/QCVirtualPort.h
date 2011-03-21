#import <QCPort.h>

@interface QCVirtualPort : QCPort
{
    id _value;
    BOOL _valueIsObject;
    unsigned int _lastObjectTimestamp;
    void *unused3[2];
}

+ (Class)baseClass;
- (id)rawValue;
- (void)setRawValue:(id)value;
- (BOOL)acceptValuesOfClass:(Class)class;
- (Class)valueClass;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;

@end

@interface QCVirtualPort (Override)
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (void)dealloc;
- (id)value;
- (BOOL)setValue:(id)value;
- (BOOL)canConnectToPort:(QCPort *)port;
- (BOOL)takeValue:(id)fp8 fromPort:(QCPort *)port;
- (unsigned int)_timestamp;
@end

@interface QCVirtualPort (Tooltip)
- (id)tooltipString;
@end


