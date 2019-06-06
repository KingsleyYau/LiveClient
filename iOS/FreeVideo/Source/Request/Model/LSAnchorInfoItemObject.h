//
//  LSAnchorInfoItemObject
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSAnchorInfoItemObject : NSObject
/**
 * 主播信息结构体
 * address              联系地址
 * anchorType           主播类型
 * isLive               是否正在公开直播（0：否，1：是）
 * introduction         主播个人介绍
 * roomPhotoUrl         主播封面
 */
@property (nonatomic, copy) NSString* _Nonnull address;
@property (nonatomic, assign) AnchorLevelType anchorType;
@property (nonatomic, assign) BOOL isLive;
@property (nonatomic, copy) NSString* _Nonnull introduction;
@property (nonatomic, copy) NSString* _Nonnull roomPhotoUrl;

@end
