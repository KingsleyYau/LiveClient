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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 跟踪显示屏幕
    if( !self.isPage ) {
        [[LiveModule module].analyticsManager reportShowScreen:self assignScreenName:self.screenName];
    }
}

- (void)reportScreenForce {
    [[LiveModule module].analyticsManager reportShowScreen:self assignScreenName:self.screenName];
}

- (BOOL)isPage {
    return NO;
}

- (void)removeFromParentViewController {
    [[LiveModule module].analyticsManager reportRemoveParentViewController:self];
    [super removeFromParentViewController];
}

@end
