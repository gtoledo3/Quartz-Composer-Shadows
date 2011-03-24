@interface SoftShadows : QCPatch
{
	QCNumberPort	*inputLightX;
	
	QCOpenGLPort_Color	*inputLightColor;
	
	QCBooleanPort	*inputBypass;
	
	QCNumberPort	*inputXRotation;
	QCNumberPort	*inputYRotation;
	QCNumberPort	*inputZRotation;
	
	
	//QCImagePort		*outputImage;
}


+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;

-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
