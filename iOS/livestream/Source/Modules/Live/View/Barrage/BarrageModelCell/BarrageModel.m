//
//  BarrageModel.m
//  BarrageDemo
//
//  Created by siping ruan on 16/9/14.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import "BarrageModel.h"

@implementation BarrageModel
- (id)init {
    if( self = [super init] ) {
        
    }
    return self;
}

- (CGFloat)cellWidth {
    CGFloat width = 0;
    CGFloat widthName = [self.name sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}].width;
    CGFloat widthMessage = [self.message sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0]}].width;
    width = (widthName > widthMessage)?widthName:widthMessage;
    return width + 80;
}

+ (instancetype)barrageModelForName:(NSString *)name message:(NSString *)message urlWihtUserID:(NSString *)userId {
    
    BarrageModel *item = [[BarrageModel alloc] init];
    item.name = name;
    item.message = message;
    item.level = PriorityLevelHigh;
    // 传用户ID获取图片url
    item.url = userId;
    
    return item;
}

@end
