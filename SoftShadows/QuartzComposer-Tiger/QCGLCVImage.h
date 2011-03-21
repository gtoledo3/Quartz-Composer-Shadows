#import <QCGLImage.h>

@class QCPBuffer;

@interface QCGLCVImage : QCGLImage
{
    BOOL _colorCorrection;
    CVBufferRef *_image;
    CVBufferRef *_imageTexture;
    CIImage *_imageCI;
    QCPBuffer *_imageBuffer;
}

- (id)initWithCVImageBuffer:(CVBufferRef *)cvimage options:(NSDictionary*)options;
- (void)finalize;
- (void)dealloc;

@end

@interface QCGLCVImage (Override)
- (BOOL)_createTexture;
- (void)_deleteTexture;
- (BOOL)_uploadTexture:(BOOL)fp8;
- (BOOL)_downloadTexture;
- (CIImage*)CIImage;
@end


