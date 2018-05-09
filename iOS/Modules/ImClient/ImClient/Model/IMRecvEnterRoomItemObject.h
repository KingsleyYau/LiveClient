
//
//  IMRecvEnterRoomItemObject.h
//  livestream
//
//  Created by Max on 2018/4/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMUserInfoItemObject.h"
#import "IMGiftNumItemObject.h"

@interface IMRecvEnterRoomItemObject : NSObject

/**
 * 观众/主播进入多人互动直播间信息
 * @roomId            直播间ID
 * @isAnchor          是否主播（0：否，1：是）
 * @userId            观众/主播ID
 * @nickName          观众/主播昵称
 * @photoUrl          观众/主播头像url
 * @userInfo          观众信息
 * @pullUrl           视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
 * @bugForList        已收吧台礼物列表
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) BOOL isAnchor;
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, strong) IMUserInfoItemObject *_Nonnull userInfo;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull pullUrl;
@property (nonatomic, strong) NSArray<IMGiftNumItemObject *> *_Nonnull bugForList;
@end
