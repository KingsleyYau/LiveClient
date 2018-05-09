//
//  InstantInviteItem.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAnchorImManager.h"

@interface InstantInviteItem : NSObject

@property (nonatomic, copy) NSString *inviteId;
@property (nonatomic, assign) ZBReplyType replyType;
@property (nonatomic, assign) ZBIMReplyType imReplyType;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) ZBRoomType roomType;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *avatarImg;

@end
