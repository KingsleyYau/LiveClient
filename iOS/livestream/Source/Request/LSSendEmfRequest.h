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
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable loiId;
@property (nonatomic, copy) NSString* _Nullable emfId;
@property (nonatomic, copy) NSString* _Nullable content;
@property (nonatomic, strong) NSArray<NSString *>* _Nullable imgList;
@property (nonatomic, assign) LSLetterComsumeType comsumeType;
@property (nonatomic, strong) SendEmfFinishHandler _Nullable finishHandler;
@end
