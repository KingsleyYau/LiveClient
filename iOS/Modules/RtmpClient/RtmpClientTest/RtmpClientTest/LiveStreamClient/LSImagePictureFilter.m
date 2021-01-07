//
//  LSImagePictureFilter.m
//  RtmpClientTest
//
//  Created by Max on 2021/1/5.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "LSImagePictureFilter.h"
NSString *const kGPUImagePictureFragmentShaderString = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
 
    void main() {
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    }
);

@interface LSImagePictureFilter() {
    GPUImagePicture *_picture;
}
@end

@implementation LSImagePictureFilter
- (id)initWithImage:(UIImage *)image {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePictureFragmentShaderString])) {
        return nil;
    }
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];
    
    return self;
}

- (void)addTarget:(id<GPUImageInput>)newTarget {
    [_picture addTarget:newTarget];
}

- (void)removeTarget:(id<GPUImageInput>)targetToRemove {
    [_picture removeTarget:targetToRemove];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    [_picture processImage];
}
@end
