//
//  BookingPrivateInviteItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

/**
 * 预约私密结构体
 * @invitationId       邀请ID
 * @toId               接受者ID
 * @fromId             发送者ID
 * @oppositePhotoUrl   对端头像
 * @oppositeNickName   对端昵称
 * @read		       已读状态（0:未读 1:已读）
 * @intimacy           亲密度
 * @replyType          状态（1:待确定 2:已接受 3:已拒绝 4:超时 5:取消 6:主播缺席 7:观众缺席 8:已完成）
 * @bookTime		   预约时间（1970年起的秒数）
 * @giftId		       礼物ID（可无）
 * @giftName		   礼物名称（可无， 仅giftId存在才存在）
 * @giftBigImgUrl	   礼物高质量图标url（可无，仅仅giftId存在才存在）
 * @giftSmallImgUrl	   礼物低质量图标url（可无，仅仅giftId存在才存在）
 * @giftNum		       礼物数量
 * @validTime		   邀请的剩余邮箱时间（秒， 可无，仅replyType＝1存在）
 * @roomId		       直播间ID（可无，仅replyType＝2存在）
 */

@interface BookingPrivateInviteItemObject : NSObject
@property (nonatomic, copy)   NSString* invitationId;
@property (nonatomic, copy)   NSString* toId;
@property (nonatomic, copy)   NSString* fromId;
@property (nonatomic, copy)   NSString* oppositePhotoUrl;
@property (nonatomic, copy)   NSString* oppositeNickName;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) int intimacy;
@property (nonatomic, assign) BookingReplyType replyType;
@property (nonatomic, assign) NSInteger bookTime;
@property (nonatomic, copy)   NSString* giftId;
@property (nonatomic, copy)   NSString* giftName;
@property (nonatomic, copy)   NSString* giftBigImgUrl;
@property (nonatomic, copy)   NSString* giftSmallImgUrl;
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) int validTime;
@property (nonatomic, copy)   NSString* roomId;



@end
