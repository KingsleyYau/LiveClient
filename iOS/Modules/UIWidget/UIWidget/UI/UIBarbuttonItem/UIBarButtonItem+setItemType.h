//
//  UIBarButtonItem+setItemType.h
//  CommonWidget
//
//  Created by lance on 16/3/8.
//  用于自定义设置导航栏的样式
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (setItemType)
/** 创建自定义的导航栏按*/
+ (UIBarButtonItem *)barButtonItemWithNormalImage:(NSString *)normalBtnName HighlightImage:(NSString *)highImageName normaltitle:(NSString *)normaltitle Highlighted:(NSString *)HighlightedTitle target:(id)target action:(SEL)action;
@end
