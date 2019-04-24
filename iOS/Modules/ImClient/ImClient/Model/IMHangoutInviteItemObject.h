//
// IMHangoutInviteItemObject.h
//  dating
//
//  Created by Alex on 19/1/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface IMHangoutInviteItemObject : NSObject
/**
 * 多人邀请信息
 * logId            记录ID
 * isAuto           是否自动邀请
 * anchorId         主播ID
 * nickName         主播昵称
 * cover            封面图URL
 * InviteMessage    邀请内容
 * weights          权重值
 * avatarImg        主播头像
 */
@property (nonatomic, assign) int logId;
@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull anchorNickName;
@property (nonatomic, copy) NSString* _Nonnull anchorCover;
@property (nonatomic, copy) NSString* _Nonnull InviteMessage;
@property (nonatomic, assign) int weights;
@property (nonatomic, copy) NSString* _Nonnull avatarImg;

@end
