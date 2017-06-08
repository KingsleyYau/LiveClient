//
//  LiveStreamClient.h
//  livestream
//
//  Created by Max on 2017/4/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImage.h"
#import "RtmpPlayer.h"
#import "RtmpPublisher.h"

@interface LiveStreamClient : NSObject

/**
 主播界面
 */
@property (nonatomic, weak) GPUImageView* _Nullable publishView;

/**
 观众界面
 */
@property (nonatomic, weak) UIImageView* _Nullable playView;

@property (nonatomic, assign) BOOL beauty;

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

@end
