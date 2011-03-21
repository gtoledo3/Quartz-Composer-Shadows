#import <GFPort.h>

@class QCProxyPort;

@interface QCPort : GFPort
{
    Class _baseClass;
    QCPort *_connectedPort;
    unsigned int _timestamp;
    unsigned int _previousTimestamp;
    BOOL _updated;
    NSString *_keyCache;
    int _direction;
    QCProxyPort *_proxyPort;
    unsigned int _connectedPortTimestamp;
    void *_observationInfo;
    void *unused2[4];
}

+ (BOOL)accessInstanceVariablesDirectly;
+ (BOOL)automaticallyNotifiesObserversForKey:(id)fp8;
+ (id)allocWithZone:(NSZone *)fp8;
+ (Class)baseClass;
- (id)initWithNode:(id)fp8 arguments:(id)fp12;
- (id)key;
- (void)portWillDeleteFromNode;
- (id)value;
- (BOOL)setValue:(id)fp8;
- (BOOL)acceptValuesOfClass:(Class)fp8;
- (Class)valueClass;
- (BOOL)canConnectToPort:(id)fp8;
- (BOOL)takeValue:(id)fp8 fromPort:(id)fp12;
- (id)ownerPatch;
- (BOOL)wasUpdated;
- (unsigned int)_timestamp;
- (void)_updateTimestamp;
- (void)willChangeValue;
- (void)didChangeValue;
- (id)stateValue;
- (BOOL)setStateValue:(id)fp8;
- (id)state;
- (BOOL)setState:(id)fp8;
- (BOOL)_execute:(double)fp8 arguments:(id)fp16;
- (void)_resetUpdate;
- (id)_proxyPort;
- (void)_setProxyPort:(id)fp8;
- (id)_connectedPort;
- (void)_setConnectedPort:(id)fp8;
- (void)_setDirection:(int)direction;
- (int)_direction;
- (Class)baseClass;
- (void)_setBaseClass:(Class)fp8;
- (id)description;
- (id)valueForKey:(id)fp8;
- (void)setValue:(id)fp8 forKey:(id)fp12;
- (void)addObserver:(id)fp8 forKeyPath:(id)fp12 options:(unsigned int)fp16 context:(void *)fp20;
- (void)removeObserver:(id)fp8 forKeyPath:(id)fp12;
- (void)setObservationInfo:(void *)fp8;
- (void *)observationInfo;
- (id)_argumentsFromAttributesKey:(id)fp8 originalArguments:(id)fp12;

@end

