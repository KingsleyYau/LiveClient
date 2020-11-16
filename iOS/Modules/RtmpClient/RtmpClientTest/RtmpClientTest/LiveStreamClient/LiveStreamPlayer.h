//
//  LiveStreamPlayer.h
//  livestream
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RtmpPlayerOC.h"

#import "GPUImage.h"

@class LiveStreamPlayer;
@protocol LiveStreamPlayerDelegate <NSObject>
@optional
- (NSString * _Nullable)playerShouldChangeUrl:(LiveStreamPlayer * _Nonnull)player;
- (void)playerOnConnect:(LiveStreamPlayer * _Nonnull)player;
- (void)playerOnDisconnect:(LiveStreamPlayer * _Nonnull)player;
- (void)playerOnInfoChange:(LiveStreamPlayer * _Nonnull)player videoDisplayWidth:(int)videoDisplayWidth vieoDisplayHeight:(int)vieoDisplayHeight;
- (void)playerOnStats:(LiveStreamPlayer * _Nonnull)player fps:(unsigned int)fps bitrate:(unsigned int)bitrate;
- (void)playerOnError:(LiveStreamPlayer * _Nonnull)player code:(NSString * _Nullable)code description:(NSString * _Nullable)description;
- (void)playerOnFinish:(LiveStreamPlayer * _Nonnull)player;
@end

@interface LiveStreamPlayer : NSObject
///**
// 显示界面
// */
//@property (strong, nonatomic) GPUImageView* _Nullable playView;

/**
 委托
 */
@property (weak) id<LiveStreamPlayerDelegate> _Nullable delegate;

/**
缓存时间
*/
@property (nonatomic, assign) NSInteger cacheMS;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL mute;

/**
 播放速度
 */
@property (nonatomic, assign) float playbackRate;

/**
 自定义滤镜
 */
@property (strong) GPUImageFilter *customFilter;

/**
 是否硬解码
 */
@property (nonatomic, assign) BOOL useHardDecoder;

/**
 当前播放URL
 */
@property (strong, readonly) NSString * _Nonnull url;

/**
 当前播放Filepath
 */
@property (strong, readonly) NSString * _Nonnull filePath;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)instance;

/**
 增加播放界面
 
 @param playView 播放界面
 */
- (void)addPlayView:(GPUImageView * _Nonnull)playView;

/**
 移除播放界面
 
 @param playView 播放界面
 */
- (void)removePlayView:(GPUImageView * _Nonnull)playView;
    
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
 播放文件
 
 @param filePath 文件绝对路径
 */
- (BOOL)playFilePath:(NSString * _Nonnull)filePath;

/**
 停止
 */
- (void)stop;

@end
