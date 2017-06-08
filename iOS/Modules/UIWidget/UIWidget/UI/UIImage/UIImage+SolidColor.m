//
//  UIImage+SolidColor.m
//  UIWidget
//
//  Created by test on 16/6/28.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImage+SolidColor.h"

@implementation UIImage (SolidColor)


- (UIImage *)createImageWithColor:(UIColor *)color imageRect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
