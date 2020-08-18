//
//  LSGiftManagerItem.m
//  livestream
//
//  Created by randy on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGiftManagerItem.h"
#import "LSFileCacheManager.h"

@interface LSGiftManagerItem()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate> {
    NSString *_giftId;
}

@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;

@end

@implementation LSGiftManagerItem
- (NSString *)giftId {
    if( _giftId == nil && self.infoItem ) {
        _giftId = self.infoItem.giftId;
    }
    return _giftId;
}

- (void)stop {
    if (self.session) {
        [self.session invalidateAndCancel];
        self.session = NULL;
    }
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = NULL;
    }
//    [self.timer invalidate];
//    self.timer = nil;
//    self.time = 0;
}

- (LSYYImage *)bigGiftImage {
    LSYYImage *image = nil;

    if (self.bigGiftFilePath) {
        NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:self.bigGiftFilePath];
        image = [LSYYImage imageWithData:imageData];
    }

    if (!image) {
        // 加载本地缓存文件失败, 删除
        [[LSFileCacheManager manager] removeDirectory:self.bigGiftFilePath];
    }

    return image;
}

- (UIImage *)barGiftImage {
    UIImage *image = nil;
    
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.infoItem.middleImgUrl]];
    image =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    if (!image) {
        // 下载大图
        [self downloadImage:self.infoItem.bigImgUrl];
    }
    return image;
}

- (NSString *)bigGiftFilePath {
    NSString *filePath = nil;
    if (self.infoItem) {
        filePath = [[LSFileCacheManager manager] bigGiftCachePathWithGiftId:self.giftId];
    }
    return filePath;
}

- (void)download {
    if (self.infoItem.type != GIFTTYPE_COMMON && self.infoItem.type != GIFTTYPE_BAR) {
        // 下载大礼物WebP文件
        [self downloadBigGift:self.infoItem.srcwebpUrl];
    }
    // 下载小图
    [self downloadImage:self.infoItem.smallImgUrl];
    // 下载中图
    [self downloadImage:self.infoItem.middleImgUrl];
    // 下载大图
    [self downloadImage:self.infoItem.bigImgUrl];
}

- (GiftSendType)canSend:(NSInteger)loveLevel userLevel:(NSInteger)userLevel {
    if (self.infoItem.loveLevel > loveLevel) {
        return GiftSendType_Not_LoveLevel;
    } else if (self.infoItem.level > userLevel) {
        return GiftSendType_Not_UserLevel;
    } else {
        return GiftSendType_Can_Send;
    }
}

#pragma mark - 下载礼物文件
- (void)downloadImage:(NSString *)url {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
    if (!image) {
        // TODO:下载礼物图片
        NSLog(@"LSGiftManagerItem::downloadImage( [礼物图片下载], giftId : %@, url : %@ )", self.giftId, url);
        if (url && url.length > 0) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager loadImageWithURL:[NSURL URLWithString:url]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
                                 
                             }
                            completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                                if (image) {
                                }
                            }];
        }
    }
}

- (void)downloadBigGift:(NSString *)url {
    // TODO:下载大礼物WebP
    if (!self.bigGiftImage) {
        NSLog(@"LSGiftManagerItem::downloadBigGift( [礼物WebP下载], giftId : %@, url : %@, path : %@ )", self.giftId, url, self.bigGiftFilePath);
        // 删除旧的文件
        [[LSFileCacheManager manager] removeDirectory:self.bigGiftFilePath];

        if (url && url.length > 0) {
            self.isDownloading = YES;
            // alex
             [self stop];
                NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.giftId];
                //系统根据当前性能自动处理后台任务的优先级
                config.discretionary = YES;
                  self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
            //    NSURL* url = [NSURL URLWithString:@"http://demo-mobile.chnlove.com/test/mp4/flash_to_mov_to_mp4.mp4"];
                NSURL* strUrl = [NSURL URLWithString:url];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:strUrl];

                self.downloadTask = [self.session downloadTaskWithRequest:request];

                [self.downloadTask resume];
            
        }
    }
}
#pragma mark -delegate
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
        [self stop];
//    [self copyFileAtPath:[location relativePath] fromVId:self.vId];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *path = [location relativePath];
    NSString *toPath = self.bigGiftFilePath;

    if (![fileManager fileExistsAtPath:toPath]) {
        [fileManager copyItemAtPath:path toPath:toPath error:&error];
        if (error) {
            NSLog(@"copy error--%@",error.description);
            return;
        }
    }
    
    self.isDownloading = NO;
    if ([self.delegate respondsToSelector:@selector(giftDownloadStateChange:)]) {
        [self.delegate giftDownloadStateChange:self];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self stop];
         self.isDownloading = NO;
        if ([self.delegate respondsToSelector:@selector(giftDownloadStateChange:)]) {
            [self.delegate giftDownloadStateChange:self];
        }
    }
}

@end
