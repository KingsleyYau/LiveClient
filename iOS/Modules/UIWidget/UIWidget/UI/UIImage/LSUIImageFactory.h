//
//  LSUIImageFactory.h
//  UIWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSUIImageFactory : NSObject
+ (UIImage *)createImageWithColor:(UIColor *)color imageRect:(CGRect)rect;
@end
