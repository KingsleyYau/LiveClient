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

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) SDWebImageCallBack callBack;
@property (weak) id<SDWebImageOperation> operation;
@end

@implementation LSImageViewLoader

+ (instancetype)loader {
    LSImageViewLoader *loader = [[LSImageViewLoader alloc] init];
    return loader;
}

+ (void)gobalInit {
    [SDWebImageDownloader sharedDownloader].username = @"test";
    [SDWebImageDownloader sharedDownloader].password = @"5179";
}

- (id)init {
    self = [super init];

    if (self) {
        self.view = nil;
        self.image = nil;
    }
    return self;
}

- (void)stop {
    self.view = nil;
    self.image = nil;
    [self.operation cancel];
    self.operation = nil;
}

- (void)loadImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage {
    self.view = view;
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
    if (cacheImage) {
        // 设置缓存图片
        [self displayImage:cacheImage];
        
        if (self.callBack) {
            self.callBack(cacheImage);
        }
        
    } else {
        // 设置预览图
        [self displayImage:placeholderImage];
        
        WeakObject(self, weakSelf);
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        self.operation = [manager loadImageWithURL:[NSURL URLWithString:url]
            options:option|SDWebImageAllowInvalidSSLCertificates
            progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            }
            completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if( error ) {
                        NSLog(@"LSImageViewLoader::loadImageWithImageView( imageURL : %@, error : %@ )", imageURL, error);
                    }
                    
                    if (image) {
                        [self displayImage:image];
                    }

                    if (weakSelf.callBack) {
                        weakSelf.callBack(image);
                    }
                });
            }];
    }
}

- (void)sdWebImageLoadView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(SDWebImageCallBack)finishHandler {

    self.callBack = finishHandler;
    [self loadImageWithImageView:view options:option imageUrl:url placeholderImage:placeholderImage];
}

- (void)displayImage:(UIImage *)image {
    if (image != nil && self.view && [self.view respondsToSelector:@selector(setImage:)]) {
        // 下载成功并且能显示图像
        [self.view performSelector:@selector(setImage:) withObject:image];
    }
}

- (void)refreshCachedImage:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage {
    self.view = view;
    [self displayImage:placeholderImage];
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:option progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSLog(@"LSImageViewLoader::refreshCachedImage( imageURL : %@, error : %@ )", imageURL, error);

        if (image) {
            [self displayImage:image];
        }
    }];
//    UIImageView *headView = (UIImageView *)view;
//    [headView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:image options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//        NSLog(@"LSImageViewLoader::refreshCachedImage( imageURL : %@, error : %@ , view : %p, image : %@)", imageURL, error, view, image);
//    }];
    
}


//- (BOOL)loadImage {
//    //    NSLog(@"LSImageViewLoader::loadImage( tid : %d, %@, view : %@ )", tid, self, self.view);
//    if (self.image) {
//        // 直接显示图片
//        return [self displayImage:YES];
//
//    } else if (self.path && self.path.length > 0) {
//        // 尝试加在缓存图片
//        NSData *data = [NSData dataWithContentsOfFile:self.path];
//        self.image = [UIImage imageWithData:data];
//
//        if (self.image) {
//            // 直接显示图片
//            return [self displayImage:YES];
//
//        } else if (self.url && self.url.length > 0) {
//            // 下载图片
//            if (self.downloadTask && self.downloadTask.originalRequest) {
//                // 存在旧的请求
//                if ([self.url isEqualToString:[self.downloadTask.originalRequest.URL absoluteString]]) {
//                    // 如果是同一个请求
//                    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
//                        // 并且在进行中
//                        return YES;
//                    }
//
//                } else {
//                    // 取消旧的
//                    [self.downloadTask cancel];
//                }
//            }
//
//            NSURL *url = [NSURL URLWithString:self.url];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//            self.downloadTask = [[AFNetWorkHelpr shareInstrue].manager downloadTaskWithRequest:request
//                progress:^(NSProgress *_Nonnull downloadProgress) {
//                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ downloadProgress : %@ ] )", downloadProgress);
//
//                }
//                destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
//                    NSURL *documentsDirectoryURL = nil;
//                    if (self.path) {
//                        documentsDirectoryURL = [NSURL fileURLWithPath:self.path];
//                    }
//                    return documentsDirectoryURL;
//
//                }
//                completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
//                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ response : %@ ] )", response);
//                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ filePath : %@ ] )", filePath);
//                    //                NSLog(@"LSImageViewLoader::loadImage( completionHandler[ error : %@ ] )", error);
//                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                        if (error == nil && ((NSHTTPURLResponse *)response).statusCode == 200) {
//                            // 显示图片
//                            NSData *data = [NSData dataWithContentsOfFile:self.path];
//                            self.image = [UIImage imageWithData:data];
//
//                            [self displayImage:YES];
//
//                            return;
//                        }
//                    }
//
//                    [self displayImage:NO];
//
//                }];
//
//            // 开始下载
//            [self.downloadTask resume];
//
//        } else {
//            // 无url失败
//            return NO;
//        }
//
//    } else {
//        // 又无图片又无缓存路径失败
//        return NO;
//    }
//
//    return YES;
//}

@end
