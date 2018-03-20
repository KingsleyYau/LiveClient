//
//  LSGoogleAnalyticsViewController.m
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "LSGoogleAnalyticsViewController.h"
#import "LSAnalyticsManager.h"
#import "LiveModule.h"

@implementation LSGoogleAnalyticsViewController

- (void)dealloc {

    // 跟踪屏幕销毁[LSRequestManager manager].invalidRequestId
    if (self) {
          [[LSAnalyticsManager manager] reportDeallocScreen:self];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 跟踪屏幕创建
    [[LSAnalyticsManager manager] reportAllocScreen:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 跟踪显示屏幕
    [[LSAnalyticsManager manager] reportShowScreen:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 跟踪屏幕消失
    [[LSAnalyticsManager manager] reportDismissScreen:self];
}

- (void)reportDidShowPage:(NSUInteger)index {
    // 跟踪屏幕页切换
    [[LSAnalyticsManager manager] reportDidShowPage:self pageIndex:index];
}

@end
