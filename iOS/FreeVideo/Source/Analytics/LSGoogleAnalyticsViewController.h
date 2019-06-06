//
//  LSGoogleAnalyticsViewController.h
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "LSGoogleAnalyticsViewController.h"
#import "LSViewController.h"

@interface LSGoogleAnalyticsViewController : LSListViewController
/**
 是否GA分页界面
 */
@property (nonatomic, assign, readonly) BOOL isPage;

/**
 自定义的GA屏幕名称
 */
@property (nonatomic, copy) NSString *screenName;

/**
 强制提交屏幕, 因为部分界面跳转可能没有动画和推进, 不会触发viewWillAppear
 */
- (void)reportScreenForce;
@end
