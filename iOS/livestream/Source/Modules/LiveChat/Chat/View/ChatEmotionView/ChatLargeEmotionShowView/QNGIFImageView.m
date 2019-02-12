//
//  QNGIFImageView.m
//  dating
//
//  Created by Calvin on 16/12/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "QNGIFImageView.h"
@interface GIFManager : NSObject
@property (nonatomic, strong) CADisplayLink  *displayLink;
@property (nonatomic, strong) NSHashTable    *gifViewHashTable;
+ (GIFManager *)shared;
- (void)stopGIFView:(QNGIFImageView *)view;
@end
@implementation GIFManager
+ (GIFManager *)shared{
    static GIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GIFManager alloc] init];
    });
    return _sharedInstance;
}
- (id)init{
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}
- (void)play{
    for (QNGIFImageView *imageView in _gifViewHashTable) {
        [imageView performSelector:@selector(play)];
    }
}
- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopGIFView:(QNGIFImageView *)view{
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}
@end

#import "QNGIFImageView.h"

@interface QNGIFImageView(){
    size_t              _index;
    size_t              _frameCount;
    float               _timestamp;
    CGImageSourceRef    _gifSourceRef;
}
@end

@implementation QNGIFImageView

- (void)removeFromSuperview{
    [super removeFromSuperview];
    [self stopGIF];
}

- (void)startGIF{
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
             if (![[GIFManager shared].gifViewHashTable containsObject:self]) {
                 if ((self.gifData || self.gifPath)) {
                     CGImageSourceRef gifSourceRef;
                     if (self.gifData) {
                         gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
                     }else{
                         gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
                     }
                     if (!gifSourceRef) {
                         gifSourceRef = CGImageSourceCreateIncremental(NULL);
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[GIFManager shared].gifViewHashTable addObject:self];
                         _gifSourceRef = gifSourceRef;
                         _frameCount = CGImageSourceGetCount(gifSourceRef);
                         if( self.delegate != nil && [self.delegate respondsToSelector:@selector(gifWillPlay)]) {
                            [self.delegate gifWillPlay];
                         }
                     });
                 }
             }
         });
         if (![GIFManager shared].displayLink) {
             [GIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[GIFManager shared] selector:@selector(play)];
             [[GIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
         }

}

- (void)stopGIF{
    if (_gifSourceRef) {
        CFRelease(_gifSourceRef);
        _gifSourceRef = nil;
    }
    [[GIFManager shared] stopGIFView:self];
}

- (void)play{
    float nextFrameDuration = self.gifSpeed!=0?self.gifSpeed:[self frameDurationAtIndex:MIN(_index+1, _frameCount-1)];
    if (_timestamp < nextFrameDuration) {
        _timestamp += [GIFManager shared].displayLink.duration;
        return;
    }
    _index ++;
    _index = _index%_frameCount;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
    self.layer.contents = (__bridge id)(ref);
    CGImageRelease(ref);
    _timestamp = 0;
}

- (BOOL)isGIFPlaying{
    return _gifSourceRef?YES:NO;
}

- (float)frameDurationAtIndex:(size_t)index{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, index, NULL);
    if( dictRef ) {
        NSDictionary *dict = (__bridge NSDictionary *)dictRef;
        NSDictionary *gifDict = (dict[(__bridge NSString *)kCGImagePropertyGIFDictionary]);
        NSNumber *unclampedDelayTime = gifDict[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
        NSNumber *delayTime = gifDict[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        CFRelease(dictRef);
        if (unclampedDelayTime.floatValue) {
            return unclampedDelayTime.floatValue;
        }else if (delayTime.floatValue) {
            return delayTime.floatValue;
        }else{
            return 1/24.0;
        }
    }
    return 1/24.0;
}

#pragma 创建GIF
//合成GIF
+ (NSString *)createGIFPath:(NSString *)path imageArray:(NSArray *)imgs
{
    //图像目标
    CGImageDestinationRef destination;
    
    //创建输出路径
    //NSString *path = [GIFLocationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",name]];
    
    //创建CFURL对象
    /*
     CFURLCreateWithFileSystemPath(CFAllocatorRef allocator, CFStringRef filePath, CFURLPathStyle pathStyle, Boolean isDirectory)
     
     allocator : 分配器,通常使用kCFAllocatorDefault
     filePath : 路径
     pathStyle : 路径风格,我们就填写kCFURLPOSIXPathStyle 更多请打问号自己进去帮助看
     isDirectory : 一个布尔值,用于指定是否filePath被当作一个目录路径解决时相对路径组件
     */
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)path,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    
    //通过一个url返回图像目标
    destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imgs.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.15], (__bridge NSString *)kCGImagePropertyGIFDelayTime, nil]
                                     forKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
    
    //设置gif信息
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    
    [dict setObject:(__bridge NSString *)kCGImagePropertyColorModelRGB forKey:(__bridge NSString *)kCGImagePropertyColorModel];
    
    [dict setObject:[NSNumber numberWithInt:8] forKey:(__bridge NSString*)kCGImagePropertyDepth];
    
    [dict setObject:[NSNumber numberWithInt:0] forKey:(__bridge NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
    //合成gif
    for (UIImage* dImg in imgs)
    {
        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CFRelease(url);
    return path;
}
@end
