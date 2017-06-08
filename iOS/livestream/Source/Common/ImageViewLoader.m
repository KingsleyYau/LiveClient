//
//  ImageViewLoader.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ImageViewLoader.h"

@interface ImageViewLoader ()

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) UIActivityIndicatorView* loadingView;
@property (nonatomic, retain) NSURLSessionDownloadTask* downloadTask;
@property (nonatomic ,weak) NSError *error;
@end

@implementation ImageViewLoader
+ (instancetype)loader {
    ImageViewLoader* loader = [[ImageViewLoader alloc] init];
    return loader;
}

- (id)init {
    if( self = [super init] ) {
//        self.manager = [[AFHTTPSessionManager manager] initWithBaseURL:nil];
        self.downloadTask = nil;
        self.delegate = nil;
        self.view = nil;
        self.image = nil;
        self.sdWebImageView = nil;
    }
    return self;
}

- (void)stop {
//    NSLog(@"ImageViewLoader::stop( tid : %d, %@, view : %@ )", tid, self, self.view);
    self.delegate = nil;
    self.view = nil;
    self.image = nil;
    [self.downloadTask cancel];
}

- (BOOL)loadImageWithOptions:(SDWebImageOptions)option placeholderImage:(UIImage *)image {
    
    if ( self.sdWebImageView != nil ) {
        
        [self.sdWebImageView sd_setImageWithURL:[NSURL URLWithString:self.url] placeholderImage:image options:option completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            if (error) {
                NSLog(@"loadImageError:%@",error);
                self.error = error;
            }else{
                self.error = nil;
            }
        }];
        
        if (self.error) {
            return NO;
        }else{
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)displayImage:(BOOL)success {
//    NSLog(@"ImageViewLoader::displayImage( tid : %d, %@, success : %d, view : %@ )", tid, self, success, self.view);
    if( success && self.image != nil && self.view && [self.view respondsToSelector:@selector(setImage:)] ) {
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
