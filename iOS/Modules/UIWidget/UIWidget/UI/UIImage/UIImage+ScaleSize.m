//
//  UIImage+ScaleSize.m
//  UIWidget
//
//  Created by test on 16/8/31.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImage+ScaleSize.h"

@implementation UIImage (ScaleSize)

- (UIImage *)scaleToSize:(CGSize)size{
    //创建一个bitmap的context
    //并把它设置成为当前使用context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束
    UIGraphicsEndImageContext();
    // 返回改变大小的图片
    return scaledImage;
}

@end
