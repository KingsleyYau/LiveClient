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
