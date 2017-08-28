//
//  BarrageModel.h
//  BarrageDemo
//
//  Created by siping ruan on 16/9/14.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarrageModelAble.h"

@interface BarrageModel : NSObject<BarrageModelAble>

@property (assign, nonatomic) PriorityLevel level;

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *name;

+ (instancetype)barrageModelForName:(NSString *)name message:(NSString *)message urlWihtUserID:(NSString *)userId;

@end
