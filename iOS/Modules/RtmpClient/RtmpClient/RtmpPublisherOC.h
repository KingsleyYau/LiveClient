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

@class RtmpPublisherOC;
@protocol RtmpPublisherOCDelegate <NSObject>
@optional
- (void)rtmpPublisherOCOnConnect:(RtmpPublisherOC * _Nonnull)rtmpClient;
- (void)rtmpPublisherOCOnDisconnect:(RtmpPublisherOC * _Nonnull)rtmpClient;
- (void)rtmpPublisherOCOnError:(RtmpPublisherOC * _Nonnull)rtmpClient code:(NSString * _Nullable)code description:(NSString * _Nullable)description;
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

/**
 是否使用硬解码
 */
@property (nonatomic, assign, readonly) BOOL useHardEncoder;

#pragma mark - 获取实例
/**
 获取实例
 @param width 视频宽
 @param height 视频高
 @return 实例
 */
+ (instancetype _Nonnull)instance:(NSInteger)width height:(NSInteger)height fps:(NSInteger)fps keyInterval:(NSInteger)keyInterval bitRate:(NSInteger)bitRate;

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
