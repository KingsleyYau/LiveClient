//
//  LSImageViewLoader.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@class LSImageViewLoader;

typedef void (^SDWebImageCallBack)( UIImage *image );

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
 *  停止请求
 */
- (void)stop;

/**
 *  加载图片
 *
 *  view 加载图片view
 *  option 枚举参数
 *  imageUrl 图片URL
 *  placeholderImage 占位图
 */
- (void)loadImageWithImageView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)image;

- (void)sdWebImageLoadView:(UIView *)view options:(SDWebImageOptions)option imageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage finishHandler:(SDWebImageCallBack)finishHandler;

//- (BOOL)loadImage;

@end
