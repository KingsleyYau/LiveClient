//
//  UIBarButtonItem+setItemType.h
//  CommonWidget
//
//  Created by lance on 16/3/8.
//  用于自定义设置导航栏的样式
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIBarButtonItem+setItemType.h"

@implementation UIBarButtonItem (setItemType)

+ (UIBarButtonItem *)barButtonItemWithNormalImage:(NSString *)normalBtnName HighlightImage:(NSString *)highImageName normaltitle:(NSString *)normaltitle Highlighted:(NSString *)HighlightedTitle target:(id)target action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:normaltitle forState:UIControlStateNormal];
    [btn setTitle:HighlightedTitle forState:UIControlStateHighlighted];
    if (normalBtnName.length) {
        [btn setImage:[UIImage imageNamed:normalBtnName] forState:UIControlStateNormal];
    }
    
    if (highImageName.length) {
        [btn setImage:[UIImage imageNamed:highImageName] forState:UIControlStateHighlighted];
    }
    
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    
    [btn sizeToFit];
    
    return [[self alloc] initWithCustomView:btn];
}


@end
