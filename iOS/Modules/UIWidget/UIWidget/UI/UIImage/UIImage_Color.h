//
//  UIImage_Color.h
//  UIWidget
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Color)
+ (UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect;
+ (UIImage *)imageWithRGBA:(CGFloat *)rgba rect:(CGRect)rect;
@end
