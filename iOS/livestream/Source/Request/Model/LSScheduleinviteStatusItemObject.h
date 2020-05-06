//
//  LSScheduleinviteStatusItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSScheduleinviteStatusItemObject : NSObject
{

}
/**
 * 预付费邀请状态结构体
 * needStartNum                 已经开始的数量(1)
 * beStartNum                     将要开始的数量(0)
 * beStrtTime                       将要开始的时间(GMT时间戳)(0)
 * startLeftSeconds             开始剩余秒数(0)
 */
@property (nonatomic, assign) int needStartNum;
@property (nonatomic, assign) int beStartNum;
@property (nonatomic, assign) NSInteger beStrtTime;
@property (nonatomic, assign) int startLeftSeconds;
@end
