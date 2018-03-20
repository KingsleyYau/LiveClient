//
//  ImInviteIdItemObject.h
//  dating
//
//  Created by Alex on 17/09/07.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

/**
 * 立即私密邀请结构体
 * @invitationId			邀请ID
 * @oppositeId              对端ID
 * @oppositeNickName		对端昵称
 * @oppositePhotoUrl		对端头像
 * @oppositeLevel		    对端等级
 * @oppositeAge             对端年龄
 * @oppositeCountry		    对端国家
 * @read                    已读状态（false：未读，true：已读）
 * @inviTime                邀请时间（1970年起的秒数）
 * @replyType               回复状态（ZBIMREPLYTYPE_UNCONFIRM：待确定，ZBIMREPLYTYPE_AGREE：已接受，ZBIMREPLYTYPE_REJECT：已拒绝，ZBIMREPLYTYPE_OUTTIME：超时，
                                     ZBIMREPLYTYPE_CANCEL：观众/主播取消，ZBIMREPLYTYPE_ANCHORABSENT：主播缺席，ZBIMREPLYTYPE_FANSABSENT：观众缺席，
                                     ZBIMREPLYTYPE_COMFIRMED：已完成）
 * @validTime               邀请的剩余有效时间（秒）（可无，仅reply_type = 2 存在）
 * @roomId                  直播间ID(可无， 仅reply_type = 1 存在)
 */

@interface ZBImInviteIdItemObject : NSObject
@property (nonatomic, copy) NSString* invitationId;
@property (nonatomic, copy) NSString* oppositeId;
@property (nonatomic, copy) NSString* oppositeNickName;
@property (nonatomic, copy) NSString* oppositePhotoUrl;
@property (nonatomic, assign) int oppositeLevel;
@property (nonatomic, assign) int oppositeAge;
@property (nonatomic, copy) NSString* oppositeCountry;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) NSInteger inviTime;
@property (nonatomic, assign) ZBIMReplyType replyType;
@property (nonatomic, assign) int validTime;
@property (nonatomic, copy) NSString* roomId;



@end
