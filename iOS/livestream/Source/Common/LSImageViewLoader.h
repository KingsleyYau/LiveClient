//
//  LSImageViewLoader.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIView+WebCache.h"

@class LSImageViewLoader;

typedef void (^LSImageViewLoaderCallBack)(UIImage *image);

@interface LSImageViewLoader : NSObject

@property (nonatomic, assign) BOOL animated;

/**
 *  创建实例
 *
 *  @return 实例
 */
+ (instancetype)loader;

+ (void)gobalInit;

/**
 停止请求
 */
- (void)stop;

/**
 加载图片
 
 @param view 加载图片view
 @param option 枚举参数
 @param url 图片URL
 @param placeholderImage 占位图
 */
- (void)loadImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler;

/**
 加载图片(仅用于需要处理304的链接)用于全局主播头像

 @param imageView 加载图片view
 @param url 图片URL
 @param placeholderImage 默认图片
 */
- (void)loadImageFromCache:(UIImageView *)imageView options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler;

/**
 加载高清图片 (仅用于列表加载的大图)
 
 @param view 加载图片view
 @param option 枚举参数
 @param url 图片URL
 @param placeholderImage 占位图
 */
- (void)loadHDListImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(LSImageViewLoaderCallBack)finishHandler;
@end
