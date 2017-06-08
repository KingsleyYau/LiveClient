//
//  AnimationImageView.h
//  UIWidget
//
//  Created by test on 16/9/23.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationImageView : UIImageView


/** 动画数组 */
@property (nonatomic,copy) NSMutableArray *animationImageArray;


- (void)imageAnimation;
@end
