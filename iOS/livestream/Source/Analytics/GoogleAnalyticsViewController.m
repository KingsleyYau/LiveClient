//
//  GoogleAnalyticsViewController.m
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "GoogleAnalyticsViewController.h"
//#import "AnalyticsManager.h"

@implementation GoogleAnalyticsViewController

- (void)dealloc {
    // 跟踪屏幕销毁
//    [[AnalyticsManager manager] reportDeallocScreen:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 跟踪屏幕创建
//    [[AnalyticsManager manager] reportAllocScreen:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [AppDelegate() setCurrentViewController:self];
    // 跟踪显示屏幕
//    [[AnalyticsManager manager] reportShowScreen:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    if (AppDelegate().currentViewController == self) {
//        AppDelegate().currentViewController = nil;
//    }
    // 跟踪屏幕消失
//    [[AnalyticsManager manager] reportDismissScreen:self];
}

#pragma mark - 接口
- (void)reportDidShowPage:(NSUInteger)index
{
    // 跟踪屏幕页切换
//    [[AnalyticsManager manager] reportDidShowPage:self pageIndex:index];
}
@end
