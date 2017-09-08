//
//  RideInfoObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RideInfoObject : NSObject
/* 座驾ID */
@property (nonatomic, copy) NSString * _Nonnull rideId;
/* 座驾图片url */
@property (nonatomic, copy) NSString * _Nonnull photoUrl;
/* 座驾名称 */
@property (nonatomic, copy) NSString * _Nonnull name;

@end
