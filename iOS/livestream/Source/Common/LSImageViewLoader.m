//
//  LSImageViewLoader.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSImageViewLoader.h"

#import "UIImageView+LSYYWebImage.h"

@interface LSImageViewLoader ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
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

    [YYWebImageManager sharedManager].username = @"test";
    [YYWebImageManager sharedManager].password = @"5179";
}

- (id)init {
    self = [super init];

    if (self) {
        NSLog(@"LSImageViewLoader::init( self : %@ )", self);

        self.view = nil;
        self.image = nil;
    }

    return self;
}

- (void)dealloc {
    NSLog(@"LSImageViewLoader::dealloc( self : %@ )", self);
}

- (void)stop {
    self.view = nil;
    self.image = nil;
    [self.operation cancel];
    self.operation = nil;
}

- (void)displayImage:(UIImage *)image {
    if (image != nil && self.view && [self.view respondsToSelector:@selector(setImage:)]) {
        // 下载成功并且能显示图像
        [self.view performSelector:@selector(setImage:) withObject:image];
    }
}

- (void)loadImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler {
    NSLog(@"LSImageViewLoader::loadImageWithImageView( self : %@, url : %@ )", self, url);
    
    self.view = view;
    
    // 设置默认图
    [self displayImage:placeholderImage];
    
    // 显示缓存
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
    if (cacheImage) {
        // 显示缓存
        [self displayImage:cacheImage];
        if (finishHandler) {
            finishHandler(cacheImage);
        }
    } else {
        // 网络下载
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        self.operation = [manager loadImageWithURL:[NSURL URLWithString:url]
                                           options:option | SDWebImageAllowInvalidSSLCertificates
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
                                              
                                          }
                                         completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (error) {
                                                     NSLog(@"LSImageViewLoader::loadImageWithImageView( imageURL : %@, error : %@ )", imageURL, error);
                                                 }
                                                 
                                                 if (image) {
                                                     [self displayImage:image];
                                                 }
                                                 
                                                 if (finishHandler) {
                                                     finishHandler(image);
                                                 }
                                             });
                                         }];
    }

}

- (void)loadImageFromCache:(UIImageView *)imageView options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler {
    NSLog(@"LSImageViewLoader::loadImageFromCache( self : %@, url : %@ )", self, url);

    self.view = imageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:url];
        if (!image) {
            image = placeholderImage;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView yy_setImageWithURL:[NSURL URLWithString:url]
                              placeholder:image
                                  options:YYWebImageOptionRefreshImageCache
                               completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError *_Nullable error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (image) {
                                           [self displayImage:image];
                                       }
                                       if (finishHandler) {
                                           finishHandler(image);
                                       }
                                   });
                               }];
        });
    });
}



- (void)loadHDListImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler {
    NSLog(@"LSImageViewLoader::loadHDListImageWithImageView( self : %@, url : %@ )", self, url);
    
    self.view = view;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 显示缓存
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
        if (cacheImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示缓存
                [self displayImage:cacheImage];
                if (finishHandler) {
                    finishHandler(cacheImage);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 设置默认图
                [self displayImage:placeholderImage];
            });
            // 网络下载
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            self.operation = [manager loadImageWithURL:[NSURL URLWithString:url]
                                               options:option | SDWebImageAllowInvalidSSLCertificates
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
                                                  
                                              }
                                             completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (error) {
                                                         NSLog(@"LSImageViewLoader::loadHDListImageWithImageView( imageURL : %@, error : %@ )", imageURL, error);
                                                     }
                                                     
                                                     if (image) {
                                                         [self displayImage:image];
                                                     }
                                                     
                                                     if (finishHandler) {
                                                         finishHandler(image);
                                                     }
                                                 });
                                             }];
        }
    });
}
@end
