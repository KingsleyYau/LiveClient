//
//  LSGoogleAnalyticsViewController.m
//  dating
//
//  Created by Max on 16/6/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  跟踪UIViewController父类

#import "LSGoogleAnalyticsViewController.h"

@implementation LSGoogleAnalyticsViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)reportScreenForce {
}

- (BOOL)isPage {
    return NO;
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
}

@end
