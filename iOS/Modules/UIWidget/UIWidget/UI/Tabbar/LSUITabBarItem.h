//
//  LSUITabBarItem.h
//  UIWidget
//
//  Created by Max on 2018/1/26.
//  Copyright © 2018年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSUITabBarItem : UITabBarItem
@property (nonatomic, copy) NSString *badgeValue;

@property (nonatomic, assign) BOOL isShowNum;
@end
