
//
//  ImAuthorityItemObject.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 权限Object
 */
@interface ImAuthorityItemObject : NSObject

/**
 * 权限
 * isHasOneOnOneAuth        是否有私密直播开播权限
 * isHasBookingAuth         是否有预约私密直播开播权限
 */

@property (nonatomic, assign) BOOL isHasOneOnOneAuth;
@property (nonatomic, assign) BOOL isHasBookingAuth;


@end
