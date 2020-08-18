//
//  LSVideoSlider.m
//  livestream
//
//  Created by Calvin on 2020/8/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSVideoSlider.h"

@implementation LSVideoSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    bounds = [super trackRectForBounds:bounds]; // 必须通过调用父类的trackRectForBounds 获取一个 bounds 值，否则 Autolayout 会失效，UISlider 的位置会跑偏。
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 4); // 这里面的h即为你想要设置的高度。
}

@end
