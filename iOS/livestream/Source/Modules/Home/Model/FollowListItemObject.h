//
//  FollowListItemObject.h
//  livestream
//
//  Created by lance on 2017/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FollowListItemObject : NSObject



/**
 名字
 */
@property (nonatomic,strong) NSString *firstName;

/**
 头像
 */
@property (nonatomic,strong) NSString *imageUrl;


/**
 在线
 */
@property (nonatomic, assign)  BOOL online;


@end
