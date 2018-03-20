//
//  DiscoverListItemObject.h
//  livestream
//
//  Created by lance on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoverListItemObject : NSObject

/**
 名字
 */
@property (nonatomic,strong) NSString *firstName;

/**
 头像
 */
@property (nonatomic,strong) NSString *imageUrl;


/**
 在线等描述
 */
@property (nonatomic, copy)  NSString *detailMsg;

@end
