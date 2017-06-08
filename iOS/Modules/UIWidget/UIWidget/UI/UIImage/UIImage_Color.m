//
//  UIImage_Color.m
//  UIWidget
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "UIImage_Color.h"

@implementation UIImage (Color)
+ (UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect {
    CGRect imgRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIGraphicsBeginImageContextWithOptions(imgRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, imgRect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)imageWithRGBA:(CGFloat *)rgba rect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace,rgba);
    UIColor *color = [[UIColor alloc]initWithCGColor:colorRef];
    CGColorRelease(colorRef);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithColor:color rect:rect];
}

@end
