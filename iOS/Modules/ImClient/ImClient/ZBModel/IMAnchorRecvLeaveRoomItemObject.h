
//
//  IMAnchorRecvLeaveRoomItemObject.h
//  livestream
//
//  Created by Max on 2018/4/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

@interface IMAnchorRecvLeaveRoomItemObject : NSObject

/**
 * 观众/主播退出多人互动直播间信息
 * @roomId              直播间ID
 * @isAnchor            是否主播（0：否，1：是）
 * @userId              观众/主播ID
 * @nickName            观众/主播昵称
 * @photoUrl            观众/主播头像url
 * @errNo               退出原因错误码
 * @errMsg              退出原因错误描述
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) BOOL isAnchor;
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) ZBLCC_ERR_TYPE errNo;
@property (nonatomic, copy) NSString *_Nonnull errMsg;

@end
