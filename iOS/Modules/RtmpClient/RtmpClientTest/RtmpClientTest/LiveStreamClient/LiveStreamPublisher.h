//
//  LiveStreamPublisher.h
//  livestream
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImage.h"

@class LiveStreamPublisher;
@protocol LiveStreamPublisherDelegate <NSObject>
@optional
- (NSString *)publisherShouldChangeUrl:(LiveStreamPublisher *)publisher;
- (void)publisherOnConnect:(LiveStreamPublisher *)publisher;
- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher;
- (void)publisherOnError:(LiveStreamPublisher *)publisher code:(NSString * _Nullable)code description:(NSString * _Nullable)description;
@end

typedef enum LiveStreamType {
    LiveStreamType_Audience_Private = 0, // 观众私密    240x320, 10fps, 10kfi, 400kbps
    LiveStreamType_Audience_Mutiple,     // 观众多人互动 240x240, 10fps, 10kfi, 400kbps
    LiveStreamType_ShowHost_Public,      // 主播公开    320x320, 12fps, 12kfi, 700kbps
    LiveStreamType_ShowHost_Private,     // 主播私密    240x320, 12fps, 12kfi, 700kbps
    LiveStreamType_ShowHost_Mutiple,     // 主播多人互动 240x240, 12fps, 12kfi, 500kbps
    LiveStreamType_Camshare,             // Camshare 176x144, 6fps, 6kfi, 300kbps
    LiveStreamType_480x640,              // 480x320, 10fps, 10kfi, 400kbps
} LiveStreamType;

@interface LiveStreamPublisher : NSObject
/**
 显示界面
 */
@property (weak, nonatomic) GPUImageView *publishView;

/**
 委托
 */
@property (weak) id<LiveStreamPublisherDelegate> delegate;

/**
 是否开启美颜
 */
@property (nonatomic, assign) BOOL beauty;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

/**
 自定义滤镜
 */
@property (strong) GPUImageFilter *customFilter;

/**
 当前推送URL
 */
@property (strong, readonly) NSString *url;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)instance:(LiveStreamType)liveStreamType;

/**
 发布流连接
 
 @param url 连接
 @param recordH264FilePath H264录制路径
 @param recordAACFilePath AAC录制路径
 @return 成功失败
 */
- (BOOL)pushlishUrl:(NSString *)url recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *)recordAACFilePath;

/**
 停止
 */
- (void)stop;

/**
 镜头翻转
 */
- (void)rotateCamera;

/**
 开启预览
 */
- (void)startPreview;

/**
 停止预览
 */
- (void)stopPreview;

@end
