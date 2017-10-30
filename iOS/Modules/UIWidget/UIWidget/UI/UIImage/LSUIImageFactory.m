//
//  LSUIImageFactory.m
//  UIWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSUIImageFactory.h"

@implementation LSUIImageFactory
+ (UIImage *)createImageWithColor:(UIColor *)color imageRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
