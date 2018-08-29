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
- (NSString * _Nullable)publisherShouldChangeUrl:(LiveStreamPublisher * _Nonnull)publisher;
- (void)publisherOnConnect:(LiveStreamPublisher * _Nonnull)publisher;
- (void)publisherOnDisconnect:(LiveStreamPublisher * _Nonnull)publisher;
@end

typedef enum LiveStreamType {
    LiveStreamType_Audience_Private = 0,    // 观众私密    240x320, 10fps, 10kfi, 400kbps
    LiveStreamType_Audience_Mutiple,        // 观众多人互动 240x240, 10fps, 10kfi, 400kbps
    LiveStreamType_ShowHost_Public,         // 主播公开    320x320, 12fps, 10kfi, 700kbps
    LiveStreamType_ShowHost_Private,        // 主播私密    240x320, 12fps, 10kfi, 700kbps
    LiveStreamType_ShowHost_Mutiple,        // 主播多人互动 240x240, 12fps, 10kfi, 500kbps
} LiveStreamType;

@interface LiveStreamPublisher : NSObject
/**
 显示界面
 */
@property (weak, nonatomic) GPUImageView* _Nullable publishView;

/**
 委托
 */
@property (weak) id<LiveStreamPublisherDelegate> _Nullable delegate;

/**
 是否开启美颜
 */
@property (nonatomic, assign) BOOL beauty;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

/**
 当前推送URL
 */
@property (strong, readonly) NSString * _Nonnull url;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)instance:(LiveStreamType)liveStreamType;

/**
 发布流连接
 
 @param url 连接
 @param recordH264FilePath H264录制路径
 @param recordAACFilePath AAC录制路径
 @return 成功失败
 */
- (BOOL)pushlishUrl:(NSString * _Nonnull)url recordH264FilePath:(NSString * _Nullable)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath;

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
