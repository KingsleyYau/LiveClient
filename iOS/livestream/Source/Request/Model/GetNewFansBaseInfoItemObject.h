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
 * nickName      观众昵称
 * photoUrl      观众头像url
 * mountId       坐驾ID
 * mountUrl      坐驾图片url
 */
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, copy) NSString *_Nonnull mountId;
@property (nonatomic, copy) NSString *_Nonnull mountUrl;

@end
