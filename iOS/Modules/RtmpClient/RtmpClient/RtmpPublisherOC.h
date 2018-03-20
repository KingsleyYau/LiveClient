//
//  RtmpPublisherOC.h
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>

// FPS
#define FPS 15
// 关键帧间隔(每KEY_FRAME_INTERVAL帧就有一个关键帧)
#define KEY_FRAME_INTERVAL FPS
// 视频码率
#define BIT_RATE 1000 * 1000

// 音频码率
//#define BIT_RATE 600 * 1000

@class RtmpPublisherOC;
@protocol RtmpPublisherOCDelegate <NSObject>
@optional
- (void)rtmpPublisherOCOnConnect:(RtmpPublisherOC * _Nonnull)rtmpClient;
- (void)rtmpPublisherOCOnDisconnect:(RtmpPublisherOC * _Nonnull)rtmpClient;
@end

@interface RtmpPublisherOC : NSObject
/**
 委托
 */
@property (weak) id<RtmpPublisherOCDelegate> _Nullable delegate;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

#pragma mark - 获取实例
/**
 获取实例
 @param width 视频宽
 @param height 视频高
 @return 实例
 */
+ (instancetype _Nonnull)instance:(NSInteger)width height:(NSInteger)height;

/**
 发布流连接
 
 @param url 连接
 @param recordH264FilePath H264录制路径
 @param recordAACFilePath AAC录制路径
 @return 成功失败
 */
- (BOOL)publishUrl:(NSString * _Nonnull)url
recordH264FilePath:(NSString * _Nullable)recordH264FilePath
 recordAACFilePath:(NSString * _Nullable)recordAACFilePath;

/**
 停止
 */
- (void)stop;

/**
 发送视频帧
 
 @param pixelBuffer 视频数据
 */
- (void)pushVideoFrame:(CVPixelBufferRef _Nonnull)pixelBuffer;

/**
 暂停推送视频
 */
- (void)pausePushVideo;

/**
 恢复推送视频
 */
- (void)resumePushVideo;

/**
 发送音频帧
 @param sampleBuffer 音频数据
 */
- (void)pushAudioFrame:(CMSampleBufferRef _Nonnull)sampleBuffer;

@end
