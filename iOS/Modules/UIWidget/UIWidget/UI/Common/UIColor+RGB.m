//
//  UIColor+RGB.m
//  MIT Mobile
//
//  Created by fgx_lion on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)
+(UIColor*)colorWithIntRGB:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha
{
    return[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
@end
