//
//  VoucherItemObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface VoucherItemObject : NSObject
/**
 * 使用卷结构体
 * voucherType     试聊劵类型（VOUCHERTYPE_BROADCAST：直播试聊劵 VOUCHERTYPE_LIVECHAT：livechat试聊劵）
 * voucherId       试用劵ID
 * photoUrl        试用劵图标url
 * photoUrlMobile  试用券图标url（移动端使用）
 * desc            试用劵描述
 * useRoomType     可用的直播间类型（0: 不限 1:公开 2:私密）
 * anchorType      主播类型（0:不限 1:没看过直播的主播 2:指定主播）
 * anchorId        主播ID
 * anchorNcikName  主播昵称
 * anchorPhotoUrl  主播头像url
 * grantedDate     获取时间
 * startValidDate 有效开始时间
 * expDate         过期时间
 * read            已读状态（0:未读 1:已读）
 * offsetMin       试聊劵时长（分钟）
 */
@property (nonatomic, assign) VoucherType voucherType;
@property (nonatomic, copy) NSString* _Nonnull voucherId;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, copy) NSString* _Nonnull photoUrlMobile;
@property (nonatomic, copy) NSString* _Nonnull desc;
@property (nonatomic, assign) UseRoomType useRoomType;
@property (nonatomic, assign) AnchorType anchorType;
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull anchorNcikName;
@property (nonatomic, copy) NSString* _Nonnull anchorPhotoUrl;
@property (nonatomic, assign) NSInteger grantedDate;
@property (nonatomic, assign) NSInteger startValidDate;
@property (nonatomic, assign) NSInteger expDate;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) int offsetMin;

@end
