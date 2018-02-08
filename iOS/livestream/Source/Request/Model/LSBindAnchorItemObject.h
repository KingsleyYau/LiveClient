//
//  LSBindAnchorItemObject
//  dating
//
//  Created by Alex on 18/1/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSBindAnchorItemObject : NSObject
/**
 * 绑定主播结构体
 * anchorId             主播ID
 * useRoomType          可用的直播间类型（USEROOMTYPE_LIMITLESS：不限，USEROOMTYPE_PUBLIC：公开，USEROOMTYPE_PRIVATE：私密）
 * expTime              试用券到期时间（1970年起的秒数）
 */
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, assign) UseRoomType useRoomType;
@property (nonatomic, assign) NSInteger expTime;


@end
