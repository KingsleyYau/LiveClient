//
//  LSHangoutListItemObject.h
//  dating
//
//  Created by Alex on 18/1/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFriendsInfoItemObject.h"
/**
 * Hang-out列表
 * anchorId         主播ID
 * nickName         主播昵称
 * avatarImg        主播头像url
 * coverImg         直播间封面图url
 * onlineStatus     主播在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）
 * friendsNum       好友数量
 * invitationMsg    主播邀请语
 * friendsInfoList  好友信息列表
 */
@interface LSHangoutListItemObject : NSObject
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *avatarImg;
@property (nonatomic, copy) NSString *coverImg;
@property (nonatomic, assign) OnLineStatus onlineStatus;
@property (nonatomic, assign) int friendsNum;
@property (nonatomic, copy) NSString *invitationMsg;
@property (nonatomic, strong) NSMutableArray<LSFriendsInfoItemObject *>* friendsInfoList;

@end
