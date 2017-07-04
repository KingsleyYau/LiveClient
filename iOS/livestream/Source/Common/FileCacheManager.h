//
//  FileCacheManager.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileCacheManager : NSObject

+ (instancetype)manager;

/**
 *  接口日志目录
 *
 *  @return 接口日志目录
 */
- (NSString *)requestLogPath;

/**
 *  崩溃日志目录
 *
 *  @return 崩溃日志目录
 */
- (NSString *)crashLogPath;

/**
 *  临时目录
 *
 *  @return 崩溃日志目录
 */
- (NSString *)tmpPath;

/**
 *  图片缓存目录
 *
 *  @param url 图片URL
 *
 *  @return 图片缓存目录
 */
- (NSString *)imageCachePathWithUrl:(NSString* )url;

/*
 *  图片上传目录
 *
 *  @param tempImage 图片
 *  @param uploadImageName 图片文件保存文字
 *
 *  @return 图片缓存路径
 */
- (NSString *)imageUploadCachePath:(UIImage *)image fileName:(NSString *)fileName;

/**
 *  大礼物文件缓存目录
 *
 *  @param giftId 礼物ID
 *
 *  @return 图片缓存目录
 */
- (NSString* )bigGiftCachePathWithGiftId:(NSString* )giftId;

/**
 *  发送礼物列表缓存目录
 *
 *  @param giftId 礼物ID
 *
 *  @return 图片缓存目录
 */
- (NSString* )sendGiftListCachePathWithGiftId:(NSString* )giftId;

/**
 *  聊天礼物缓存目录
 *
 *  @param giftId 礼物ID
 *
 *  @return 图片缓存目录
 */
- (NSString* )chatGiftCachePathWithGiftId:(NSString* )giftId;

/**
 *  获取相册图片缓存路径
 *
 *  @param image 图片
 *  @param fileName  文件名
 *
 *  @return 图片缓存路径
 */
- (NSString *)imageCacheFromPhoneAlbumnPath:(UIImage *)image fileName:(NSString *)fileName;

@end
