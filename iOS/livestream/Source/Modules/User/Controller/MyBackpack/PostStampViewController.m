//
//  PostStampViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/8/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PostStampViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "IntroduceView.h"
#import "LiveModule.h"

@interface PostStampViewController ()

@end

@implementation PostStampViewController

- (void)dealloc {
    NSLog(@"PostStampViewController::dealloc()");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isShowTaBar = YES;
    self.isFirstProgram = YES;
    self.requestUrl = [LSConfigManager manager].item.postStampUrl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupRequestWebview {
    [super setupRequestWebview];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MyBackPackGetUnreadCount" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


@end
