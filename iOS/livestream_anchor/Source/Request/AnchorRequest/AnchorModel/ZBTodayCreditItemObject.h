//
//  ZBTodayCreditItemObject.h
//  dating
//
//  Created by Alex on 18/3/1.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBTodayCreditItemObject : NSObject
/**
 * 获取收入信息结构体
 * monthCredit            本月产出数
 * monthCompleted       本月开播已完成天数
 * monthTarget          本月开播计划天数
 * monthProgress        本月已开播进度（整型）（取值范围为0-100）
 */
@property (nonatomic, assign) int monthCredit;
@property (nonatomic, assign) int monthCompleted;
@property (nonatomic, assign) int monthTarget;
@property (nonatomic, assign) int monthProgress;


@end
