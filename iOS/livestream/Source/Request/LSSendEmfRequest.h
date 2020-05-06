//
//  LSSendEmfRequest.h
//  dating
//   13.5.发送信件
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSendEmfRequest : LSSessionRequest
/**
 * anchorId                      主播ID
 * loiId                         回复的意向信ID（可无，无则为不是回复）
 * emfId                         回复的信件ID（可无，无则为不是回复）
 * content                       回复信件内容
 * imgList                       附件数组
 * comsumeType                   付费类型（LSLETTERCOMSUMETYPE_CREDIT：信用点，LSLETTERCOMSUMETYPE_STAMP：邮票）
 * sayHiResponseId               SayHi的回复ID（可无，无则表示不是回复）
 * isSchedule              是否预付费直播邀请
 * timeZoneId              时区ID
 * startTime              邀请开始时间（格式： yyyy-mm-dd hh:00:00）
 * duration               分钟时长
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable loiId;
@property (nonatomic, copy) NSString* _Nullable emfId;
@property (nonatomic, copy) NSString* _Nullable content;
@property (nonatomic, strong) NSArray<NSString *>* _Nullable imgList;
@property (nonatomic, assign) LSLetterComsumeType comsumeType;
@property (nonatomic, copy) NSString* _Nullable sayHiResponseId;
@property (nonatomic, assign) BOOL isSchedule;
@property (nonatomic, copy) NSString* _Nullable timeZoneId;
@property (nonatomic, copy) NSString* _Nullable startTime;
@property (nonatomic, assign) int duration;
@property (nonatomic, strong) SendEmfFinishHandler _Nullable finishHandler;
@end
