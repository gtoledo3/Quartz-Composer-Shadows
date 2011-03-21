#import <QCPort.h>
#import <QCObjectPort.h>
#import <QCStructure.h>

@interface QCStructurePort : QCObjectPort
{
}

+ (Class)baseClass;
- (Class)objectClass;
- (QCStructure*)structureValue;
- (void)setStructureValue:(QCStructure*)structure;

@end

@interface QCStructurePort (Tooltip)
- (void)_printStructure:(id)fp8 toString:(id)fp12 linePrefix:(id)fp16;
- (id)tooltipString;
@end

@interface QCStructurePort (Override)
- (BOOL)acceptValuesOfClass:(Class)classType;
- (BOOL)setValue:(id)fp8;
@end

@interface QCStructurePort (ParameterView)
- (id)setupParameterView;
- (void)resetParameterView:(id)fp8;
@end
