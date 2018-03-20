//
//  BookTimeItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface BookTimeItemObject : NSObject
/**
 *
 * timeId			 预约时间ID
 * time              预约时间（1970年起的秒数）
 * status            预约时间状态（0:可预约 1:本人已邀请 2:本人已确认）
 */
@property (nonatomic, copy) NSString *_Nonnull timeId;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) BookTimeStatus status;

@end
