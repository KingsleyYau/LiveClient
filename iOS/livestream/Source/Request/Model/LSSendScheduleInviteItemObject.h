//
//  LSSendScheduleInviteItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSSendScheduleInviteItemObject : NSObject
{

}
/**
 * 预付费邀请结构体
 * inviteId                         邀请ID(S36841326)
 * isSummerTime            选中的时区是否夏令时(0)
 * startTime                    开始时间GMT时间戳(1587783600)
 * addTime                    添加时间GMT时间戳(1587699207)
 */
@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, assign) BOOL isSummerTime;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger addTime;

@property (nonatomic,assign) int duration;
@end
