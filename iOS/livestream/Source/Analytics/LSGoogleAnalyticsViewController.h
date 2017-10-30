//
//  LSGoogleAnalyticsViewController.h
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "LSGoogleAnalyticsViewController.h"
#import "LSViewController.h"

@interface LSGoogleAnalyticsViewController : LSViewController

/**
 显示分页

 @param index 分页下标
 */
- (void)reportDidShowPage:(NSUInteger)index;

@end
