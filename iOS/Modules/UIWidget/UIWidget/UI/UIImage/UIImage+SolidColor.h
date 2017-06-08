//
//  UIImage+SolidColor.h
//  UIWidget
//
//  Created by test on 16/6/28.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SolidColor)

/** 生成纯色图片 */
- (UIImage *)createImageWithColor:(UIColor *)color imageRect:(CGRect)rect;

@end
