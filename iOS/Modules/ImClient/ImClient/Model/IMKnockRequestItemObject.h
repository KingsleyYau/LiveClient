
//
//  IMKnockRequestItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface IMKnockRequestItemObject : NSObject

/**
 * 敲门信息
 * @roomId              直播间ID
 * @anchorId            主播ID
 * @nickName            主播昵称
 * @photoUrl            主播头像
 * @age                 年龄
 * @country             国家
 * @knockId             敲门ID
 * @expire              敲门请求的有效剩余秒数
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString *_Nonnull country;
@property (nonatomic, copy) NSString *_Nonnull knockId;
@property (nonatomic, assign) int expire;

@end
