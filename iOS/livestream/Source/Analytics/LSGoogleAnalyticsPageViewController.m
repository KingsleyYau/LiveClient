//
//  LSGoogleAnalyticsPageViewController.m
//  livestream
//
//  Created by Max on 2018/10/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsPageViewController.h"

#import "LiveModule.h"

@interface LSGoogleAnalyticsPageViewController ()

@end

@implementation LSGoogleAnalyticsPageViewController
- (BOOL)isPage {
    return YES;
}

- (void)reportDidShowPage:(NSUInteger)index {
    // 跟踪屏幕页切换
    [[LiveModule module].analyticsManager reportDidShowPage:self pageIndex:index];
}

@end
