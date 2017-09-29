//
//  UIImage+Combine.m
//  UIWidget
//
//  Created by test on 2017/9/11.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "UIImage+Combine.h"

@implementation UIImage (Combine)

+ (UIImage *)imageCombine:(UIImage *)oneImage otherImage:(UIImage *)otherImage viewHeight:(CGFloat)height{
    CGSize resultSize = CGSizeMake(oneImage.size.width, oneImage.size.height);
    UIGraphicsBeginImageContext(resultSize);
  
    CGRect oneRect = CGRectMake(0, 0, resultSize.width, oneImage.size.height);
    [oneImage drawInRect:oneRect];
    CGFloat centerHeight = height * 0.5f - 10;
    [otherImage drawAtPoint:CGPointMake( centerHeight,centerHeight)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}



+ (UIImage *)imageCombine:(UIImage *)oneImage otherImage:(UIImage *)otherImage viewSize:(CGSize)viewSize{
//    CGSize resultSize = CGSizeMake(oneImage.size.width, oneImage.size.height);
    UIGraphicsBeginImageContext(viewSize);
    
    CGRect oneRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    [oneImage drawInRect:oneRect];
    CGFloat centerHeight = viewSize.height * 0.5f;
    [otherImage drawAtPoint:CGPointMake( centerHeight - (otherImage.size.width * 0.5),centerHeight - (otherImage.size.height * 0.5))];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
@end
