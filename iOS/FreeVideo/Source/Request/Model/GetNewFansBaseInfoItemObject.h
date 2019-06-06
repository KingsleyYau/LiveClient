//
//  GetNewFansBaseInfoItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetNewFansBaseInfoItemObject : NSObject
/**
 * 指定观众信息结构体
 * nickName         观众昵称
 * photoUrl		    观众头像url
 * riderId          座驾ID
 * riderName        座驾名称
 * riderUrl         座驾图片url
 */
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, copy) NSString *_Nonnull riderId;
@property (nonatomic, copy) NSString *_Nonnull riderName;
@property (nonatomic, copy) NSString *_Nonnull riderUrl;

@end
