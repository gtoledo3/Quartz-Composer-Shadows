#import <QCTypes.h>
#import <QCGLObject.h>

@class QCPBuffer;

@interface QCGLImage : QCGLObject
{
    int _type;
    unsigned int _pixelsWide;
    unsigned int _pixelsHigh;
    float _pixelsAspectRatio;
    unsigned int _textureName;
    unsigned int _textureTarget;
    unsigned int _textureLevels;
    float _textureMatrix[16];
    unsigned int _textureFlags;
    float _textureAnisotropy;
    int _textureWrapping;
    int _textureFiltering;
    QCBorderColor _textureBorderColor;
    void *_bufferAddress;
    unsigned int _bufferRowBytes;
    unsigned int _bufferPixelComponents;
    unsigned int _bufferPixelSize;
    unsigned int _bufferFormat;
    unsigned int _bufferType;
    void *_bufferCallback;
    void *_bufferUserInfo;
    BOOL _bufferUploaded;
    BOOL _bufferDownloaded;
    CIImage *_ciImage;
    QCPBuffer *_ciImagePBuffer;
    unsigned int _ciImageTextureName;
    NSData *_bufferData;
    NSData *_rawData;
    CGImageRef _cgImage;
    NSImage *_nsImage;
    void *_scratchBufferAddress;
    unsigned char _saveEnabled;
    void *unused3[4];
}

- (void)_finalize_QCGLImage;
- (void)finalize;
- (void)dealloc;
- (unsigned int)pixelsWide;
- (unsigned int)pixelsHigh;
- (float)pixelsAspectRatio;
- (unsigned long)textureTarget;
- (const float *)textureMatrix;
- (unsigned int)textureMipmapLevels;
- (BOOL)flipped;
- (BOOL)_setTextureParameters;
- (void)setTextureWrappingMode:(int)wrappingMode;
- (int)textureWrappingMode;
- (void)setTextureFilteringMode:(int)filteringMode;
- (int)textureFilteringMode;
- (void)setTextureAnisotropy:(float)textureAnsiotropy;
- (float)textureAnisotropy;
- (void)setTextureBorderColor:(QCBorderColor)borderColor;
- (QCBorderColor)textureBorderColor;
- (unsigned long)textureName;
- (NSData*)bufferData;
- (NSData*)rawData;
- (CGImageRef)CGImage;
- (CIImage*)CIImage;

@end

@interface QCGLImage (Private)
- (id)_initWithBaseType:(int)fp8 pixelsWide:(unsigned int)fp12 pixelsHigh:(unsigned int)fp16 options:(id)fp20;
- (void)_setBuffer:(void *)fp8 rowBytes:(unsigned int)fp12 format:(unsigned long)fp16 type:(unsigned long)fp20
	releaseCallback:(void *)fp24 userInfo:(void *)fp28;
- (void)_clearBuffer;
- (BOOL)_updateBuffer;
- (void *)_bufferAddress;
- (unsigned int)_bufferRowBytes;
- (unsigned long)_bufferFormat;
- (unsigned long)_bufferType;
- (unsigned int)_bufferPixelComponents;
- (unsigned int)_bufferPixelSize;
- (void)_createScratchBuffer;
- (void *)_scratchBufferAddress;
- (void)_setTextureOnContext:(CGLContextObj)context unit:(unsigned long)fp12 useTransformationMatrix:(BOOL)fp16;
- (void)_unsetTextureOnContext:(CGLContextObj)context unit:(unsigned long)fp12;
- (int)_baseType;
- (void)_setBaseTextureName:(unsigned long)name;
- (unsigned long)_baseTextureName;
- (const float *)_baseTextureMatrix;
@end

@interface QCGLImage (Texture)
- (BOOL)_createTexture;
- (void)_deleteTexture;
- (BOOL)_uploadTexture:(BOOL)fp8;
- (BOOL)_downloadTexture;
@end

@interface QCGLImage (Override)
- (id)init;
- (void)didChange;
- (void)didRegisterWithOpenGLContext;
- (void)willUnregisterFromOpenGLContext;
- (id)stateValue;
- (id)initWithStateValue:(id)fp8;
- (id)description;
@end

@interface QCGLImage (NSImage)
+ (Class)valueClass;
- (id)NSImage;
- (id)value;
@end

