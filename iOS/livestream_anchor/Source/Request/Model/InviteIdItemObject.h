//
//  InviteIdItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

/**
 * 立即私密邀请结构体
 * @invitationId			邀请ID
 * @oppositeId              主播ID
 * @oppositeNickName		主播头像url
 * @oppositePhotoUrl		主播昵称
 * @oppositeLevel		    主播头像url
 * @oppositeAge             主播头像url
 * @oppositeCountry		    主播头像url
 * @read                    主播头像url
 * @inviTime                主播头像url
 * @replyType               回复状态（0:拒绝 1:同意 2:未回复 3:已超时）
 * @validTime               邀请的剩余有效时间（秒）（可无，仅reply_type = 2 存在）
 * @roomId                  直播间ID(可无， 仅reply_type = 1 存在)
 */

@interface InviteIdItemObject : NSObject
@property (nonatomic, copy) NSString* invitationId;
@property (nonatomic, copy) NSString* oppositeId;
@property (nonatomic, copy) NSString* oppositeNickName;
@property (nonatomic, copy) NSString* oppositePhotoUrl;
@property (nonatomic, assign) int oppositeLevel;
@property (nonatomic, assign) int oppositeAge;
@property (nonatomic, copy) NSString* oppositeCountry;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) NSInteger inviTime;
// 回复状态（0:拒绝 1:同意 2:未回复 3:已超时）
@property (nonatomic, assign) HttpReplyType replyType;
@property (nonatomic, assign) int validTime;
@property (nonatomic, copy) NSString* roomId;



@end
