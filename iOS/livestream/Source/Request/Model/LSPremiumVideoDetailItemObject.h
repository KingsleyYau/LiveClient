//
//  LSPremiumVideoDetailItemObject
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPremiumVideoTypeItemObject.h"
#import <httpcontroller/HttpRequestEnum.h>
@interface LSPremiumVideoDetailItemObject : NSObject
/**
 * 付费视频详情结构体
 * anchorId                     主播ID
 * videoId                      视频ID
 * typeList                      该视频对应的分类列表
 * title                            视频标题
 * describe                视频描述
 * duration                     视频时长(单位:秒)
 * coverUrlPng              视频png封面地址
 * coverUrlGif               视频gif封面地址
 * videoUrlShort            短视频地址
 * videoUrlFull              完整视频地址
 * isInterested               是否感兴趣
 * lockStatus                解锁状态解锁状态(LSLOCKSTATUS_LOCK_NOREQUEST:未解锁，未发过解锁请求, LSLOCKSTATUS_LOCK_UNREPLY:未解锁，解锁请求未回复, LSLOCKSTATUS_LOCK_REPLY:未解锁，解锁请求已回复, LSLOCKSTATUS_UNLOCK:已解锁 )
 * requestId                解锁码请求ID  (lockStatus=LSLOCKSTATUS_LOCK_UNREPLY时，有值)
 * requestLastTime             请求最后发送时间(GMT时间戳) (lockStatus=LSLOCKSTATUS_LOCK_UNREPLY时，有值)
 * emfId                        信件ID (lockStatus=LSLOCKSTATUS_LOCK_REPLY时，有值)
 * unlockTime             解锁时间(GMT时间戳) (lockStatus=LSLOCKSTATUS_UNLOCK时，有值)
 * currentTime             服务器当前时间(GMT时间戳)
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* videoId;
@property (nonatomic, strong) NSMutableArray<LSPremiumVideoTypeItemObject *>* typeList;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* describe;
@property (nonatomic, assign) int duration;
@property (nonatomic, copy) NSString* coverUrlPng;
@property (nonatomic, copy) NSString* coverUrlGif;
@property (nonatomic, copy) NSString* videoUrlShort;
@property (nonatomic, copy) NSString* videoUrlFull;
@property (nonatomic, assign) BOOL isInterested;
@property (nonatomic, assign) LSLockStatus lockStatus;
@property (nonatomic, copy) NSString* requestId;
@property (nonatomic, assign) NSInteger requestLastTime;
@property (nonatomic, copy) NSString* emfId;
@property (nonatomic, assign) NSInteger unlockTime;
@property (nonatomic, assign) NSInteger currentTime;

@end
