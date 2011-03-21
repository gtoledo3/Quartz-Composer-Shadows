#import <QCGLImage.h>

@interface QCGLCGImage : QCGLImage
{
    CGImageRef _image;
    void *unused4[4];
}

- (id)initWithFile:(NSString*)filename options:(id)fp12;
- (id)initWithURL:(NSString*)url options:(id)fp12;
- (id)initWithRawData:(id)fp8 options:(id)fp12;
- (id)_initWithCGObject:(void *)fp8 bounds:(CGRect)rect bitsPerPixel:(unsigned int)bpp options:(id)fp32;
- (id)initWithCGImage:(CGImageRef)cgimage options:(NSDictionary*)options;
- (id)initWithPDFPage:(CGPDFPageRef)fp8 options:(NSDictionary*)options;
@end

@interface QCGLCGImage (Override)
- (BOOL)_downloadTexture;
@end

@interface QCGLCGImage (NSImage)
- (id)initWithNSImage:(NSImage*)nsimage options:(NSDictionary*)options;
@end

