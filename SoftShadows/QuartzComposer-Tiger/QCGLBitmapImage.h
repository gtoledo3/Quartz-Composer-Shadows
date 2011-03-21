#import <QCGLImage.h>

@interface QCGLBitmapImage : QCGLImage
{
}

- (id)initWithBuffer:(void *)data bytesPerRow:(unsigned int)bytes format:(unsigned long)format type:(unsigned long)type
	pixelsWide:(unsigned int)width pixelsHigh:(unsigned int)height
	releaseCallback:(void *)releaseCallback callbackUserInfo:(void *)userInfoCallback options:(id)options;
- (void *)buffer;
- (unsigned int)bytesPerRow;
- (void)willChangeBytes;
- (void)didChangeBytes;

@end

@interface QCGLBitmapImage (Override)
- (BOOL)_downloadTexture;
@end


