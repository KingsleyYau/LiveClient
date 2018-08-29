//
//  LSGoogleAnalyticsViewController.m
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "LSGoogleAnalyticsViewController.h"

#import "LiveModule.h"

@implementation LSGoogleAnalyticsViewController

- (void)dealloc {
    // 跟踪屏幕销毁[LSRequestManager manager].invalidRequestId 
    [[LiveModule module].analyticsManager reportDeallocScreen:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 跟踪屏幕创建
    [[LiveModule module].analyticsManager reportAllocScreen:self assignScreenName:self.gaScreenName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 跟踪显示屏幕
    [[LiveModule module].analyticsManager reportShowScreen:self assignScreenName:self.gaScreenName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 跟踪屏幕消失
    [[LiveModule module].analyticsManager reportDismissScreen:self];
}

- (void)reportDidShowPage:(NSUInteger)index {
    // 跟踪屏幕页切换
    [[LiveModule module].analyticsManager reportDidShowPage:self pageIndex:index];
}

@end
