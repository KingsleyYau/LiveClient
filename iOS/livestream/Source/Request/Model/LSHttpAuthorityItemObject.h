//
//  LSHttpAuthorityItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSHttpAuthorityItemObject : NSObject
{

}
/**
 * 权限结构体
 * isHasOneONOneAuth 是否有私密直播权限
 * isHasBookingAuth  是否有预约私密直播权限
 */

@property (nonatomic, assign) BOOL isHasOneOnOneAuth;
@property (nonatomic, assign) BOOL isHasBookingAuth;


@end
