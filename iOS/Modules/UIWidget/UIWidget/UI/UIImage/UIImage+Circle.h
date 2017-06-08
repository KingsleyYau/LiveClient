//
//  UIImage+Circle.h
//  UIWidget
//  利用画板讲图片弄成圆形
//  Created by lance on 16/4/12.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Circle)
/**
 *  画圆
 *
 *  @return 圆形image
 */
- (instancetype)circleImage;

- (UIImage *)imageWithCornerSize:(CGRect)rect Radius:(CGFloat)radius;

/**
 *  画圆
 *
 *  @param name 图片名字
 *
 *  @return 圆形image
 */
+ (instancetype)circleImage:(NSString *)name;

@end
