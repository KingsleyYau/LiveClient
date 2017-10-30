//
//  LSImageViewLoader.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSImageViewLoader.h"
#import "AFNetWorkHelpr.h"

@interface LSImageViewLoader ()

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) SDWebImageCallBack callBack;

@end

@implementation LSImageViewLoader

+ (instancetype)loader {
    LSImageViewLoader *loader = [[LSImageViewLoader alloc] init];
    return loader;
}

- (id)init {
    self = [super init];

    if (self) {
        self.downloadTask = nil;
        self.view = nil;
        self.image = nil;
    }
    return self;
}

- (void)stop {
    //    NSLog(@"LSImageViewLoader::stop( tid : %d, %@, view : %@ )", tid, self, self.view);
    self.delegate = nil;
    self.view = nil;
    self.image = nil;
    [self.downloadTask cancel];
}

- (void)loadImageWithImageView:(UIImageView *)imageView options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage {

    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
    if (image) {

        [imageView setImage:image];
        if (self.callBack) {
            self.callBack(image);
        }

    } else {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:placeholderImage
                              options:option
                            completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                                
                                if (self.callBack) {
                                    self.callBack(image);
                                }
        }];
    }
}


- (void)sdWebImageLoadView:(UIImageView *)imageView options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(SDWebImageCallBack)finishHandler {
    
    
    self.callBack = finishHandler;
    [self loadImageWithImageView:imageView options:option imageUrl:url placeholderImage:placeholderImage];
}

- (BOOL)loadImage {
    //    NSLog(@"LSImageViewLoader::loadImage( tid : %d, %@, view : %@ )", tid, self, self.view);
    if (self.image) {
        // 直接显示图片
        return [self displayImage:YES];

    } else if (self.path && self.path.length > 0) {
        // 尝试加在缓存图片
        NSData *data = [NSData dataWithContentsOfFile:self.path];
        self.image = [UIImage imageWithData:data];

        if (self.image) {
            // 直接显示图片
            return [self displayImage:YES];

        } else if (self.url && self.url.length > 0) {
            // 下载图片
            if (self.downloadTask && self.downloadTask.originalRequest) {
                // 存在旧的请求
                if ([self.url isEqualToString:[self.downloadTask.originalRequest.URL absoluteString]]) {
                    // 如果是同一个请求
                    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
                        // 并且在进行中
                        return YES;
                    }

                } else {
                    // 取消旧的
                    [self.downloadTask cancel];
                }
            }

            NSURL *url = [NSURL URLWithString:self.url];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

            self.downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request
                progress:^(NSProgress *_Nonnull downloadProgress) {
                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ downloadProgress : %@ ] )", downloadProgress);

                }
                destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
                    NSURL *documentsDirectoryURL = nil;
                    if (self.path) {
                        documentsDirectoryURL = [NSURL fileURLWithPath:self.path];
                    }
                    return documentsDirectoryURL;

                }
                completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ response : %@ ] )", response);
                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ filePath : %@ ] )", filePath);
                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ error : %@ ] )", error);
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        if (error == nil && ((NSHTTPURLResponse *)response).statusCode == 200) {
                            // 显示图片
                            NSData *data = [NSData dataWithContentsOfFile:self.path];
                            self.image = [UIImage imageWithData:data];

                            [self displayImage:YES];

                            return;
                        }
                    }

                    [self displayImage:NO];

                }];

            // 开始下载
            [self.downloadTask resume];

        } else {
            // 无url失败
            return NO;
        }

    } else {
        // 又无图片又无缓存路径失败
        return NO;
    }

    return YES;
}

- (BOOL)displayImage:(BOOL)success {
    //    NSLog(@"LSImageViewLoader::displayImage( tid : %d, %@, success : %d, view : %@ )", tid, self, success, self.view);
    if (success && self.image != nil && self.view && [self.view respondsToSelector:@selector(setImage:)]) {
        // 下载成功并且能显示图像
        [self.view performSelector:@selector(setImage:) withObject:self.image];
    }
    [self loadImageFinish:success];

    return YES;
}

- (void)loadImageFinish:(BOOL)success {
    // 回调
    if( [self.delegate respondsToSelector:@selector(loadImageFinish:success:)] ) {
        [self.delegate loadImageFinish:self success:success];
    }
}

@end
