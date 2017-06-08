//
//  SearchListObject.h
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchListObject : NSObject
/**
 * 用户头像
 */
@property (strong, nonatomic) NSString *userHeadUrl;

/**
 * 用户名称
 */
@property (strong, nonatomic) NSString *userNameStr;

/**
 * 用户ID
 */
@property (strong, nonatomic) NSString *userIDStr;

/**
 * 用户性别
 */
@property (assign, nonatomic) BOOL isMale;

/**
 * 用户等级
 */
@property (strong, nonatomic) NSString *lvStr;

/**
 * 是否关注
 */
@property (assign, nonatomic) BOOL isFollow;

@end
