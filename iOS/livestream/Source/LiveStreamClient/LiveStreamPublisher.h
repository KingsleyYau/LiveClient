//
//  LiveStreamPublisher.h
//  livestream
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImage.h"

@interface LiveStreamPublisher : NSObject
/**
 显示界面
 */
@property (nonatomic, weak) GPUImageView* _Nullable publishView;

/**
 是否开启美颜
 */
@property (nonatomic, assign) BOOL beauty;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)instance;

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

@end
