//
//  LSAccessKeyinfoItemObject
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSAccessKeyinfoItemObject : NSObject
/**
 * 视频解锁码信息结构体
 * videoId                      视频ID
 * title                            视频标题
 * description                视频描述
 * duration                     视频时长(单位:秒)
 * coverUrlPng              视频png封面地址
 * coverUrlGif               视频gif封面地址
 * accessKey                解锁码
 * accessKeyStatus     解锁码状态 （LSACCESSKEYSTATUS_NOUSE：未使用,  LSACCESSKEYSTATUS_USED：已使用）
 * validTime                解锁码有效期(GMT时间戳)
 */
@property (nonatomic, copy) NSString* videoId;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* describe;
@property (nonatomic, assign) int duration;
@property (nonatomic, copy) NSString* coverUrlPng;
@property (nonatomic, copy) NSString* coverUrlGif;
@property (nonatomic, copy) NSString* accessKey;
@property (nonatomic, assign) LSAccessKeyStatus accessKeyStatus;
@property (nonatomic, assign) NSInteger validTime;

@end
