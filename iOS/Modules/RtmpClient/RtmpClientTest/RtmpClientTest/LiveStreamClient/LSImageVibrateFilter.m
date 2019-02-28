//
//  LSImageVibrateFilter.m
//  RtmpClientTest
//
//  Created by Max on 2019/2/15.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSImageVibrateFilter.h"

NSString *const kGPUImageVibrateFragmentShaderString = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
 
    uniform lowp vec2 uImagePixel;
    uniform lowp vec2 uOffet;
 
    void main() {
        highp vec4 right = texture2D(inputImageTexture, textureCoordinate + uImagePixel * uOffet);
        highp vec4 left = texture2D(inputImageTexture, textureCoordinate - uImagePixel * uOffet);
        gl_FragColor = vec4(left.r, right.g, right.b, 1.0);
    }
);

static int VIBRATE_OFFSET_MAX = 10;
@interface LSImageVibrateFilter() {
    int _vibrateOffset;
}
@end

@implementation LSImageVibrateFilter
- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageVibrateFragmentShaderString])) {
        return nil;
    }
    
    _vibrateOffset = 5;
    
    return self;
}

- (void)setlevel:(double)level {
    _vibrateOffset = (int)(level * VIBRATE_OFFSET_MAX);
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    
    CGPoint uImagePixel = CGPointMake(1.0f / inputTextureSize.width, 1.0 / inputTextureSize.height);
    [self setPoint:uImagePixel forUniformName:@"uImagePixel"];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    
    int offset = arc4random() % _vibrateOffset;
    CGPoint uOffet = CGPointMake(offset, offset);
    [self setPoint:uOffet forUniformName:@"uOffet"];
}

@end
