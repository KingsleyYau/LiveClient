//
//  LSFileCacheManager.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSFileCacheManager : NSObject

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
 缓存目录(可以被清空)
 
 @return 绝对路径
 */
- (NSString *)cacheDirectory;

/**
 *  手机信息收集
 *
 *  @param fileName 文件名称
 *
 *  @return 手机信息目录
 */
- (NSString *)phoneInfoWithFileName:(NSString *)fileName;

/**
 *  语音已读plist
 *
 *  @param fileName 文件名称
 *
 *  @return 语音已读目录
 */
- (NSString *)voiceReadWithFileName:(NSString *)fileName;
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
/*
 *  图片上传目录
 *
 *  @param image 图片
 *  @param fileName 图片文件保存文字
 *
 *  @return 图片缓存路径
 */
- (NSString *)imageUploadSCompressSizeCachePath:(UIImage *)image fileName:(NSString *)fileName;

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

/**
 获取私密照缓存照片图片
 
 @param mailId 发送的的id
 @param photoId 图片的id
 @return 图片缓存路径
 */
- (NSString *)cachePrivatePhotoImagePath:(NSString *)mailId photoId:(NSString *)photoId;

/**
 获取emf视频流图片
 
 @param womanId 女士id
 @param sendId 发送id
 @param videoId 视频id
 @param messageId 消息id
 @return 图片缓存路径
 */
- (NSString *)cacheVideoThumbPhotoPath:(NSString *)womanId sendId:(NSString *)sendId videoId:(NSString *)videoId messageId:(NSString *)messageId;

/**
 *  删除目录
 *
 *  @param path 目录路径
 *
 *  @return 成功/失败
 */
- (BOOL)removeDirectory:(NSString*)path;



@end
