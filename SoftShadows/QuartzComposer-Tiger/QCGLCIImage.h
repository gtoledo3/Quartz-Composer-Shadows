#import <QCGLImage.h>

@class QCPBuffer;

@interface QCGLCIImage : QCGLImage
{
    CIImage *_image;
    QCPBuffer *_pBuffer;
    void *unused4[4];
}

- (id)initWithCIImage:(CIImage*)ciimage options:(NSDictionary*)options;
- (void)dealloc;

@end

@interface QCGLCIImage (Override)
- (BOOL)_createTexture;
- (void)_deleteTexture;
- (BOOL)_uploadTexture:(BOOL)fp8;
- (BOOL)_downloadTexture;
- (CIImage*)CIImage;
@end

