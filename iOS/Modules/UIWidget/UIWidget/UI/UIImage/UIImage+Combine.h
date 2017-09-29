//
//  UIImage+Combine.h
//  UIWidget
//
//  Created by test on 2017/9/11.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Combine)


/**
 合并图片

 @param oneImage 合并的第一张
 @param otherImage 另外需合并的
 @param height 合并后图的高度
 @return 合并后的图片
 */
+ (UIImage *)imageCombine:(UIImage *)oneImage otherImage:(UIImage *)otherImage viewHeight:(CGFloat)height;
+ (UIImage *)imageCombine:(UIImage *)oneImage otherImage:(UIImage *)otherImage viewSize:(CGSize)viewSize;
@end
