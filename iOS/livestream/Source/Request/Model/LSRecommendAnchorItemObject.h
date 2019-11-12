//
//  LSRecommendAnchorItemObject.h
//  dating
//
//  Created by Alex on 19/6/11.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
#import "LSHttpAuthorityItemObject.h"


@interface LSRecommendAnchorItemObject : NSObject
{

}
/**
 * 推荐主播结构体
 * anchorId         主播ID
 * anchorNickName   主播昵称
 * anchorCover      主播封面
 * anchorAvatar     主播头像
 * isFollow         是否关注（0：不关注，1：关注）
 * onlineStatus     在线状态
 * publicRoomId     公开直播间ID(空值则表示不在公开中)
 * roomType         // 直播间类型（HTTPROOMTYPE_NOLIVEROOM:（没有直播间） HTTPROOMTYPE_FREEPUBLICLIVEROOM:（免费公开直播间） HTTPROOMTYPE_COMMONPRIVATELIVEROOM:（付费公开直播间） HTTPROOMTYPE_CHARGEPUBLICLIVEROOM:（普通私密直播间） HTTPROOMTYPE_LUXURYPRIVATELIVEROOM:（豪华私密直播间））
 * priv             直播权限
 * lastCountactTime 最后联系人时间
 */

@property (nonatomic, strong) NSString* anchorId;
@property (nonatomic, strong) NSString* anchorNickName;
@property (nonatomic, strong) NSString* anchorCover;
@property (nonatomic, strong) NSString* anchorAvatar;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, assign) OnLineStatus onlineStatus;
@property (nonatomic, strong) NSString* publicRoomId;
@property (nonatomic, assign) HttpRoomType roomType;
@property (nonatomic, strong) LSHttpAuthorityItemObject* priv;
@property (nonatomic, assign) NSInteger lastCountactTime;

@end
