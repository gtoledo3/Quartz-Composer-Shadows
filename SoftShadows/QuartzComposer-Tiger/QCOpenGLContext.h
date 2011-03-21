#import <QuartzCore/QuartzCore.h>
#import <QCContext.h>
#import <QCGLObject.h>

@interface QCOpenGLContext : QCContext
{
    CGLContextObj _glContext;
    CGLPixelFormatObj _pixelFormat;
    CIContext *_ciContext;
    CVOpenGLTextureCacheRef _textureCache;
    QCGLObject **_objectList;
    unsigned int _objectCount;
    unsigned int _objectListSize;
    unsigned int _executingPatches;
    float _saveProjection[16];
    float _saveModelView[16];
    int _saveFace;
    BOOL _flipped;
    BOOL _hasFP;
    NSSize _pixelAspectRatio;
    NSRect _cleanAperture;
    NSRect _viewportFrame;
    NSRect _viewportBounds;
    NSRect _cleanViewportFrame;
    NSRect _cleanViewportBounds;
    CGLContextObj _spareGLContext;
    CGLPixelFormatObj _sparePixelFormat;
    CIContext *_spareCIContext;
    NSMutableArray *_pBufferPool;
    void *unused2[4];
}

- (id)init;
- (id)initWithCGLContextObj:(CGLContextObj)fp8 pixelFormat:(CGLPixelFormatObj)fp12 options:(id)fp16;
- (void)_finalize_QCOpenGLContext;
- (void)finalize;
- (void)dealloc;
- (CGLContextObj)CGLContextObj;
- (CGLPixelFormatObj)CGLPixelFormatObj;
- (id)CIContext;
- (CVOpenGLTextureCacheRef)textureCache;
- (CGLContextObj)_spareCGLContextObj;
- (CGLPixelFormatObj)_spareCGLPixelFormatObj;
- (id)_spareCIContext;
- (id)_pBufferWithTarget:(unsigned long)fp8 pixelsWide:(unsigned int)fp12 pixelsHigh:(unsigned int)fp16 mipmapLevels:(unsigned int)fp20;
- (void)purge;
- (void)willDestroyCGLContext;
- (void)_registerObject:(id)fp8;
- (void)_unregisterObject:(id)fp8 notify:(BOOL)fp12;
- (BOOL)_updateViewport;
- (void)willExecutePatch:(id)fp8;
- (void)didExecutePatch:(id)fp8;
- (void)setPixelAspectRatio:(NSSize)fp8;
- (NSSize)pixelAspectRatio;
- (void)setCleanAperture:(NSRect)fp8;
- (NSRect)cleanAperture;
- (void)_setFlippedRendering:(BOOL)fp8;
- (BOOL)_isFlippedRendering;
- (NSRect)viewportFrame:(BOOL)fp8;
- (NSRect)viewportBounds:(BOOL)fp8;
- (NSSize)viewportResolution;
- (BOOL)isCoreImageSupported;
- (id)description;

@end

@interface QCOpenGLContext (NSOpenGLContext)
+ (id)contextWithNSOpenGLContext:(id)fp8 format:(id)format options:(id)fp16;
- (id)initWithNSOpenGLContext:(NSOpenGLContext*)context format:(id)format options:(id)fp16;
@end

@interface QCOpenGLContext (QCUtilities)
+ (unsigned int)minSupportedTextureSizeForTarget:(unsigned long)fp8;
+ (unsigned int)maxSupportedTextureSizeForTarget:(unsigned long)fp8;
+ (BOOL)checkTextureWidth:(unsigned int *)fp8 height:(unsigned int *)fp12 forTarget:(unsigned long)fp16 outPixelRatio:(float *)fp20;
- (BOOL)isExtensionSupported:(id)fp8;
- (long)_rendererPropertyValue:(int)fp8;
- (unsigned int)videoMemorySize;
- (unsigned int)textureMemorySize;
- (long)rendererID;
@end

@interface QCOpenGLContext (FCPImageExtensions)
+ (Class)imagePortClass;
- (id)createPixelImageWithFormat:(int)fp8 baseAddress:(const void *)fp12 bytesPerRow:(unsigned int)fp16 
	releaseCallback:(void *)fp20 userInfo:(void *)fp24 
	pixelsWide:(unsigned int)fp28 pixelsHigh:(unsigned int)fp32 flipped:(BOOL)fp36;
- (id)createRenderTextureImageWithFormat:(int)fp8 target:(unsigned long)fp12 
	pixelsWide:(unsigned int)fp16 pixelsHigh:(unsigned int)fp20 flipped:(BOOL)fp24;
- (CGLContextObj)beginRenderTextureImage:(id)fp8;
- (BOOL)endRenderTextureImage:(id)fp8;
- (id)recycleRenderTextureImage:(id)fp8;
- (int)formatFromImage:(id)fp8;
- (unsigned int)pixelsWideFromImage:(id)fp8;
- (unsigned int)pixelsHighFromImage:(id)fp8;
- (BOOL)copyPixelsFromImage:(id)fp8 toBaseAddress:(void *)fp12 withBytesPerRow:(unsigned int)fp16;
- (BOOL)getPixelsFromImage:(id)fp8 outBaseAddress:(const void **)fp12 outBytesPerRow:(unsigned int *)fp16;
- (BOOL)textureFromImage:(id)fp8 outName:(unsigned int *)fp12 outFlipped:(char *)fp16;
@end

