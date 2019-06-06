//
//  LSSayHiAnchorItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
/**
 * sayHi主播列表
 * anchorId         主播ID
 * nickName         主播昵称
 * coverImg         主播封面
 * onlineStatus     在线状态（ONLINE_STATUS_LIVE：在线，ONLINE_STATUS_OFFLINE：不在线）
 * roomType         直播间类型（HTTPROOMTYPE_NOLIVEROOM:（没有直播间） HTTPROOMTYPE_FREEPUBLICLIVEROOM:（免费公开直播间） HTTPROOMTYPE_COMMONPRIVATELIVEROOM:（付费公开直播间） HTTPROOMTYPE_CHARGEPUBLICLIVEROOM:（普通私密直播间） HTTPROOMTYPE_LUXURYPRIVATELIVEROOM:（豪华私密直播间）HTTPROOMTYPE_HANGOUTLIVEROOM: (Hangout直播间)）
 */
@interface LSSayHiAnchorItemObject : NSObject
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *coverImg;
@property (nonatomic, assign) OnLineStatus onlineStatus;
// 直播间类型（HTTPROOMTYPE_NOLIVEROOM:（没有直播间） HTTPROOMTYPE_FREEPUBLICLIVEROOM:（免费公开直播间） HTTPROOMTYPE_COMMONPRIVATELIVEROOM:（付费公开直播间） HTTPROOMTYPE_CHARGEPUBLICLIVEROOM:（普通私密直播间） HTTPROOMTYPE_LUXURYPRIVATELIVEROOM:（豪华私密直播间）HTTPROOMTYPE_HANGOUTLIVEROOM:(Hangout直播间)）
@property (nonatomic, assign) HttpRoomType roomType;

@end
