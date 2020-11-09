//
//  StreamNavigationController.m
//  RtmpClientTest
//
//  Created by Max on 2020/11/9.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamNavigationController.h"

@implementation StreamNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
}

//- (void)backAction:(id)sender {
//    // ViewController自己处理是否返回
//    if ([self.topViewController respondsToSelector:@selector(backAction:)]) {
//        [self.topViewController performSelector:@selector(backAction:) withObject:sender];
//    } else {
//        [self popViewControllerAnimated:YES];
//    }
//}

//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
//    // 重定义默认后退按钮事件触发
//    UINavigationItem *backItem = navigationBar.backItem;
//
//    if ([self respondsToSelector:@selector(backAction:)]) {
//        backItem.backBarButtonItem.target = self;
//        backItem.backBarButtonItem.action = @selector(backAction:);
//    }
//
//    return YES;
//}

//- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
//    // 重定义默认后退按钮事件触发
//    UINavigationItem *backItem = navigationBar.backItem;
//
//    if ([self respondsToSelector:@selector(backAction:)]) {
//        backItem.backBarButtonItem.target = self;
//        backItem.backBarButtonItem.action = @selector(backAction:);
//    }
//}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
