//
//  LSVideoPlayManager.m
//  dating
//
//  Created by Calvin on 17/6/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSVideoPlayManager.h"
#import "LSVideoView.h"

#define TIMEOUT 90
#define VideoType @"mp4"
#define CachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface LSVideoPlayManager ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate,LSVideoViewDelegate>
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
@property (nonatomic,copy) NSString * videoPath;
@property (nonatomic,copy) NSString * vId;
@property (nonatomic,strong) LSVideoView * videoView;
@property (nonatomic,assign) BOOL isFill;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger time;
@end

@implementation LSVideoPlayManager

- (id)init {
    if( self = [super init] ) {
        self.downloadTask = nil;
        self.isFill = NO;
        self.isPlayConstant = NO;
    }
    return self;
}

- (void)stop {
    [self.session invalidateAndCancel];
    [self.downloadTask cancel];
    [self.timer invalidate];
    self.timer = nil;
    self.time = 0;
}

- (void)loadVideo:(NSString *)vId {
    if (vId == nil) {
        if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadFail)]) {
            [self.delegate onRecvVideoDownloadFail];
        }
        return;
    }
    self.vId = vId;
    
    //判断本地是否有视频，如果有，直接返回
    if ([self isLocalVideoPath:vId].length > 0) {        
        if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadSucceed:)]) {
            [self.delegate onRecvVideoDownloadSucceed:[self isLocalVideoPath:vId]];
        }
    } else {
        //如果本地没有视频，那就下载
//        if (!AppShareDelegate().isNetwork) {
//            if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadFail)]) {
//                [self.delegate onRecvVideoDownloadFail];
//            }
//        } else {
//          [self downloadVideo];
//        }
        
    }
}

- (void)downloadVideo {
    [self stop];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"download"];
    //系统根据当前性能自动处理后台任务的优先级
    config.discretionary = YES;
      self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
//    NSURL* url = [NSURL URLWithString:@"http://demo-mobile.chnlove.com/test/mp4/flash_to_mov_to_mp4.mp4"];
    NSURL* url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    
    [self.downloadTask resume];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(downloadTimeOut) userInfo:nil repeats:YES];
}

- (void)downloadTimeOut {
    self.time++;
    if (self.time >= TIMEOUT) {
       [self stop];
        if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadFail)]) {
            [self.delegate onRecvVideoDownloadFail];
        }
    }
}

#pragma mark -delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [self stop];
    [self copyFileAtPath:[location relativePath] fromVId:self.vId];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self stop];
        if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadFail)]) {
            [self.delegate onRecvVideoDownloadFail];
        }
    }
}
#pragma mark 创建本地视频路径
- (void)copyFileAtPath:(NSString *)path fromVId:(NSString *)vId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString * videoPath = [NSString stringWithFormat:@"%@/video",CachesPath];
    NSString *toPath = [videoPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",vId,VideoType]];
    if (![fileManager fileExistsAtPath:toPath]) {
        [fileManager copyItemAtPath:path toPath:toPath error:&error];
        if (error) {
            NSLog(@"copy error--%@",error.description);
            if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadFail)]) {
                [self.delegate onRecvVideoDownloadFail];
            }
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(onRecvVideoDownloadSucceed:)]) {
        [self.delegate onRecvVideoDownloadSucceed:toPath];
    }
}

- (void)setVideoAspectFill:(BOOL)isAspectFill {
    self.isFill = isAspectFill;
}

#pragma mark 判断本地是否有该视频
- (NSString *)isLocalVideoPath:(NSString *)vId {
    self.videoPath = [NSString stringWithFormat:@"%@/video",CachesPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self.videoPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",vId,VideoType]];
    if ([fileManager fileExistsAtPath:filePath]) {
        return filePath;
    } else {
        [fileManager createDirectoryAtPath:self.videoPath withIntermediateDirectories:YES attributes:nil error:nil];
        return @"";
    }
    return @"";
}

#pragma mark 删除本地视频
- (void)removeLocalVideo:(NSString *)vId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self.videoPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",vId,VideoType]];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)playVideo:(NSString*_Nonnull)path forView:(UIView *_Nonnull)view playTime:(CGFloat)playTime isShowProgress:(BOOL)isShow {
    self.videoView.delegate = nil;
    [self.videoView removeFromSuperview];
    self.videoView = nil;
    self.videoView = [[LSVideoView alloc]initWithFrame:view.bounds isShowProgress:isShow];
    self.videoView.url = path;
    self.videoView.playTime = playTime;
    self.videoView.isFill = self.isFill;
    self.videoView.isPlayContant = self.isPlayConstant;
    self.videoView.delegate = self;
    [view addSubview:self.videoView];
    [self.videoView play];
}

- (void)removeNotification{
    [self stop];
    [self.videoView removeObserveAndNOtification];
    self.videoView = nil;
}

#pragma mark - 女士详情
// 播放视频，视频的大小view，显示滑动条
- (void)playLdayVideo:(NSString*_Nonnull)path forView:(UIView *_Nonnull)view playTime:(CGFloat)playTime isShowSlider:(BOOL)isShow {
    self.videoView.delegate = nil;
    [self.videoView removeFromSuperview];
    self.videoView = nil;
    //女士详情框，是否包括滑条
    self.videoView = [[LSVideoView alloc] initWithFrame:view.bounds isSlider:isShow];
    // 视频路径
    self.videoView.url = path;
    // 是否满屏
    self.videoView.isFill = self.isFill;
    // 设置播放时间
    self.videoView.playTime = playTime;
    // 设置代理
    self.videoView.delegate = self;
    [view addSubview:self.videoView];
    // 播放女士视频
    [self.videoView playLadyVideo];
}

// 缓冲加载中
- (void)onRecvVideoViewBufferEmpty {
    if ([self.delegate respondsToSelector:@selector(onRecvVideoPlayBufferEmpty)]) {
        [self.delegate onRecvVideoPlayBufferEmpty];
    }
}

// 缓冲可以播放
- (void)onRecvVideoViewLikelyToKeepUp {
    if ([self.delegate respondsToSelector:@selector(onRecvVideoPlayLikelyToKeepUp)]) {
        [self.delegate onRecvVideoPlayLikelyToKeepUp];
    }
}

// 播放失败
- (void)onRecvVideoViewPlayFailed {
    [self removeNotification];
    [self removeLocalVideo:self.vId];
    if ([self.delegate respondsToSelector:@selector(onRecvVideoPlayFailed)]) {
        [self.delegate onRecvVideoPlayFailed];
    }
}

- (void)onRecvVideoViewPlayDone {
    [self removeNotification];
    // 播放完成
    if ([self.delegate respondsToSelector:@selector(onRecvVideoPlayDone)]) {
        [self.delegate onRecvVideoPlayDone];
    }
}

//+ (NSString *)getGiftPhotoURLPath:(NSString *)path vgId:(NSString *)vgId {
//    NSString * photo = [NSString stringWithFormat:@"%@%@%@/%@_big.jpg",[[RequestManager manager] getWebSite],path,vgId ,[[vgId toMD5String] lowercaseString]];
//    return photo;
//}
//
//+ (NSString *)getGiftVideoURLPath:(NSString *)path vgId:(NSString *)vgId {
//    NSString * video = [NSString stringWithFormat:@"%@%@%@/%@_video.%@",[[RequestManager manager] getWebSite],path,vgId ,[[vgId toMD5String] lowercaseString],VideoType];
//    return video;
//}
@end
