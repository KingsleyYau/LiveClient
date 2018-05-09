//
//  AnchorHangoutItemObject.h
//  dating
//
//  Created by Alex on 18/4/3.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnchorBaseInfoItemObject.h"

@interface AnchorHangoutItemObject : NSObject
/**
 * 多人互动直播间列表结构体
 * userId           用户Id
 * nickName         用户昵称
 * photoUrl         用户头像
 * anchorList       主播列表
 * roomId           直播间ID
 */
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, strong) NSMutableArray<AnchorBaseInfoItemObject * >*_Nonnull anchorList;
@property (nonatomic, copy) NSString *_Nonnull roomId;

@end
