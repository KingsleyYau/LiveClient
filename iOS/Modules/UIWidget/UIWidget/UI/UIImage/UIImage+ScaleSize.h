//
//  UIImage+ScaleSize.h
//  UIWidget
//
//  Created by test on 16/8/19.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScaleSize)



/**
 *  缩放到指定大小
 *
 *  @param img  图片大小
 *  @param size 目标大小
 *
 *  @return 修改完成图片
 */
- (UIImage *)scaleToSize:(CGSize)size;
@end
