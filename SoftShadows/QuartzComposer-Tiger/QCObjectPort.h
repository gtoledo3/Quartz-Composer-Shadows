#import <QCPort.h>
#import <QCVirtualPort.h>

@interface QCObjectPort : QCVirtualPort
{
    void *unused4[4];
}

+ (id)allocWithZone:(NSZone *)zone;
- (Class)objectClass;
- (id)object;
- (BOOL)setObject:(id)object;

@end

@interface QCObjectPort (Override)
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (Class)valueClass;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)fp8;
- (BOOL)canConnectToPort:(id)fp8;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
- (id)description;
@end



@interface QCObjectPort (QCGLObject)
- (id)rawValue;
@end
