//
//  GiftComboNumView.h
//  liveDemo
//
//  Created by Calvin on 17/5/31.
//  Copyright © 2017年 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftComboNumView : UIView

@property (nonatomic ,assign) NSInteger number;/**< 初始化数字 */

/**
 改变数字显示
 
 @param number 显示的数字
 */
- (void)changeNumber:(NSInteger )number;


@end
