
//
//  IMAnchorRecvOtherInviteItemObject.h
//  livestream
//
//  Created by Max on 2018/4/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMAnchorRecvOtherInviteItemObject : NSObject

/**
 * 观众邀请其它主播加入信息
 * @inviteId            邀请ID
 * @roomId              多人互动直播间ID
 * @anchorId            被邀请的主播ID
 * @nickName            被邀请的主播昵称
 * @photoUrl            被邀请的主播头像
 * @expire              邀请有效的剩余秒数
 */
@property (nonatomic, copy) NSString *_Nonnull inviteId;
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) int expire;
@end
