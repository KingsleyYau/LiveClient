//
// LSAnchorProgramItemObject.h
//  dating
//
//  Created by Alex on 18/4/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSAnchorProgramItemObject : NSObject
#import <anchorhttpcontroller/ZBHttpRequestEnum.h>
/**
 * 节目信息
 * showLiveId           节目ID
 * anchorId             主播ID
 * showTitle            节目名称
 * showIntroduce        节目介绍
 * cover                节目封面图url
 * approveTime          审核通过时间（1970年起的秒数）
 * startTime            节目开播时间（1970年起的秒数）
 * duration             节目时长
 * leftSecToStart       开始开播剩余时间（秒）
 * leftSecToEnter      可进入过渡页的剩余时间（秒）
 * price                节目价格
 * status               节目状态（PROGRAMSTATUS_UNVERIFY：未审核，PROGRAMSTATUS_VERIFYPASS：审核通过，PROGRAMSTATUS_VERIFYREJECT：审核被拒，PROGRAMSTATUS_PROGRAMEND：节目正常结束，PROGRAMSTATUS_PROGRAMCALCEL：节目已取消，PROGRAMSTATUS_OUTTIME：节目已超时）
 * isHasTicket          是否已买票
 * isHasFollow          是否已关注
 * isTicketFull         是否已满座
 */
@property (nonatomic, copy) NSString* _Nonnull showLiveId;
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull showTitle;
@property (nonatomic, copy) NSString* _Nonnull showIntroduce;
@property (nonatomic, copy) NSString* _Nonnull cover;
@property (nonatomic, assign) NSInteger approveTime;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int leftSecToStart;
@property (nonatomic, assign) int leftSecToEnter;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) AnchorProgramStatus status;
@property (nonatomic, assign) int ticketNum;
@property (nonatomic, assign) int followNum;
@property (nonatomic, assign) BOOL isTicketFull;

@end
