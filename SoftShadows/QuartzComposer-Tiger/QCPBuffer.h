@interface QCPBuffer : NSObject
{
    CGLPBufferObj _pBuffer;
    unsigned int _target;
    unsigned int _width;
    unsigned int _height;
    unsigned int _levels;
}

+ (id)pBufferWithTarget:(unsigned long)fp8 pixelsWide:(unsigned int)fp12 pixelsHigh:(unsigned int)fp16 mipmapLevels:(unsigned int)fp20;
- (id)init;
- (id)initWithTarget:(unsigned long)fp8 pixelsWide:(unsigned int)fp12 pixelsHigh:(unsigned int)fp16 mipmapLevels:(unsigned int)fp20;
- (void)finalize;
- (void)dealloc;
- (void)_destroyPBuffer;
- (BOOL)setTarget:(unsigned long)fp8 pixelsWide:(unsigned int)fp12 pixelsHigh:(unsigned int)fp16 mipmapLevels:(unsigned int)fp20;
- (CGLPBufferObj)_CGLPBufferObj;
- (unsigned long)target;
- (unsigned int)pixelsWide;
- (unsigned int)pixelsHigh;
- (unsigned int)mipmapLevels;
- (BOOL)attachToCGLContext:(CGLContextObj)cglContext;
- (BOOL)texImage:(CGLContextObj)fp8;
- (id)description;

@end

