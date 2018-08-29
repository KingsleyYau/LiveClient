//
//  LSImageViewLoader.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSImageViewLoader.h"
#import "AFNetWorkHelpr.h"
#import "UIImageView+LSYYWebImage.h"
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
    
    [YYWebImageManager sharedManager].username = @"test";
    [YYWebImageManager sharedManager].password = @"5179";
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
    
    // 设置默认图
    [self displayImage:placeholderImage];
    if (self.callBack) {
        self.callBack(placeholderImage);
    }
    
    // 有URL才处理
    if (url) {
        // 显示缓存
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
        if (cacheImage) {
            // 显示缓存
            [self displayImage:cacheImage];
            
            if (self.callBack) {
                self.callBack(cacheImage);
            }
        } else {
            // 网络下载
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

- (void)refreshCachedImage:(UIImageView *)imageView options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage {
//    self.view = imageView;
//    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:option progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
////        NSLog(@"LSImageViewLoader::refreshCachedImage( imageURL : %@, error : %@ )", imageURL, error);
//
//        if (image) {
//            [self displayImage:image];
//        }
//    }];
    
    self.view = imageView;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image =  [[YYImageCache sharedCache] getImageForKey:url];
        
        if (!image) {
            image = placeholderImage;
        }
        [imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:image options:YYWebImageOptionRefreshImageCache
                           completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (image) {
                                       
                                       [[YYImageCache sharedCache] setImage:image forKey:[NSString stringWithFormat:@"%@",url]];
                                       
                                       [self displayImage:image];
                                   }
                               });
                           }];
    });

}

@end
