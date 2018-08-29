//
//  LSGiftManagerItem.m
//  livestream
//
//  Created by randy on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGiftManagerItem.h"
#import "LSFileCacheManager.h"
#import "AFNetWorkHelpr.h"

@interface LSGiftManagerItem() {
    NSString *_giftId;
}

@end

@implementation LSGiftManagerItem
- (NSString *)giftId {
    if( _giftId == nil && self.infoItem ) {
        _giftId = self.infoItem.giftId;
    }
    return _giftId;
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

- (BOOL)canSend:(NSInteger)loveLevel userLevel:(NSInteger)userLevel {
    BOOL bFlag = NO;
    bFlag = (self.infoItem.loveLevel <= loveLevel && self.infoItem.level <= userLevel);
    return bFlag;
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
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            NSURLSessionDownloadTask *downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request
                progress:^(NSProgress *_Nonnull downloadProgress) {
//                    float pargress = downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
                }
                destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
                    NSURL *documentsDirectoryURL = nil;
                    if (self.bigGiftFilePath.length > 0) {
                        documentsDirectoryURL = [NSURL fileURLWithPath:self.bigGiftFilePath];
                    }
                    return documentsDirectoryURL;
                }
                completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
                        if (error == nil && (code == 200 || code == 304)) {
                            NSLog(@"LSGiftManagerItem::downloadBigGift( [礼物WebP下载, 成功], giftId : %@, url : %@, fileName : %@ )", self.giftId, url, [filePath lastPathComponent]);
                        } else {
                            NSLog(@"LSGiftManagerItem::downloadBigGift( [礼物WebP下载, 失败], giftId : %@, code : %d, url : %@ )", self.giftId, (int)code, url);
                        }
                    } else {
                        NSLog(@"LSGiftManagerItem::downloadBigGift( [礼物WebP下载, 失败], giftId : %@, url : %@ )", self.giftId, url);
                    }
                    
                    self.isDownloading = NO;
                    if ([self.delegate respondsToSelector:@selector(giftDownloadStateChange:)]) {
                        [self.delegate giftDownloadStateChange:self];
                    }
                }];
            // 开始下载
            [downloadTask resume];
        }
    }
}
@end
