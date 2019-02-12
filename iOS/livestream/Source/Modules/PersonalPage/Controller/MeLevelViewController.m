//
//  MeLevelViewController.m  我的等级界面
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MeLevelViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface MeLevelViewController () <WKUIDelegate,WKNavigationDelegate>

@end

@implementation MeLevelViewController

- (void)dealloc {
    NSLog(@"MeLevelViewController::dealloc()");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Level";
    
    self.isShowTaBar = YES;
    self.isFirstProgram = YES;
    
    NSString *webSiteUrl = [LSConfigManager manager].item.userLevel;
    self.requestUrl = webSiteUrl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)setupRequestWebview {
    [super setupRequestWebview];
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
