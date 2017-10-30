//
//  UIWColor.m
//  UIWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSColor.h"

@implementation LSColor
+ (UIColor *)colorWithIntRGB:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}
@end
