//
//  LSScheduleAnchorInfoItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSScheduleAnchorInfoItemObject : NSObject
{

}
/**
 * 预付费主播信息结构体
 * anchorId         主播ID(G304568)
 * nickName         昵称(MaxBB)
 * avatarImg        主播头像url(http://*****.png)
 * onlineStatus     在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）(ONLINE_STATUS_OFFLINE)
 * age              年龄(20)
 * country            国家(Ukraine)
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* avatarImg;
@property (nonatomic, assign) OnLineStatus onlineStatus;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* country;
@end
