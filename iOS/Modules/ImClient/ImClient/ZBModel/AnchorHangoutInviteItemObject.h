
//
//  AnchorHangoutInviteItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMAnchorItemObject.h"

@interface AnchorHangoutInviteItemObject : NSObject

/**
 * 互动直播间邀请信息
 * @inviteId           邀请ID
 * @userId             观众ID
 * @nickName           观众昵称
 * @photoUrl           观众头像url
 * @anchorList         已在直播间的主播列表
 * @expire             邀请有效的剩余秒数
 */
@property (nonatomic, copy) NSString *_Nonnull inviteId;
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, strong) NSArray<IMAnchorItemObject *> *_Nonnull anchorList;
@property (nonatomic, assign) int expire;

@end
