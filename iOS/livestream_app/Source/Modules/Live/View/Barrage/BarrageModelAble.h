//
//  BarrageModelAble.h
//  BarrageDemo
//
//  Created by siping ruan on 16/9/12.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  弹幕模型的优先级(影响在缓存中的显示顺序)
 */
typedef NS_ENUM(NSInteger, PriorityLevel) {
    /**
     *  低
     */
    PriorityLevelLow = 0,
    /**
     *  中
     */
    PriorityLevelMedium,
    /**
     *  高
     */
    PriorityLevelHigh,
};

/**
 *  弹幕模型对象必须要遵守的协议
 */
@protocol BarrageModelAble <NSObject>

@required
/**
 *  模型对象显示的优先级
 */
@property (assign, nonatomic) PriorityLevel level;
/**
 *  cell的宽度
 */
- (CGFloat)cellWidth;

@end
