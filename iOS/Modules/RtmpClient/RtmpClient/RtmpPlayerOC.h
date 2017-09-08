//
//  RtmpPlayerOC.h
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>

@class RtmpPlayerOC;
@protocol RtmpPlayerOCDelegate <NSObject>

- (void)rtmpPlayerRenderVideoFrame:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC buffer:(CVPixelBufferRef _Nonnull)buffer;
- (void)rtmpPlayerOnDisconnect:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC;
- (void)rtmpPlayerOnPlayerOnDelayMaxTime:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC;
@end

@interface RtmpPlayerOC : NSObject

/**
 委托
 */
@property (weak) id<RtmpPlayerOCDelegate> _Nullable delegate;

/**
 录制目录
 */
@property (readonly) NSString* _Nullable recordFilePath;

/**
 是否使用硬解码
 */
@property (assign) BOOL useHardDecoder;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)instance;

/**
 播放流连接
 
 @param url 连接
 @param recordFilePath 录制路径
 @param recordH264FilePath H264录制路径
 @param recordAACFilePath AAC录制路径
 @return 成功失败
 */
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString * _Nullable)recordFilePath recordH264FilePath:(NSString * _Nullable)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath;

/**
 停止
 */
- (void)stop;

@end
