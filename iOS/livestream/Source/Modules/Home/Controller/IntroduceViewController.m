//
//  IntroduceViewController.m
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IntroduceViewController.h"
#import "LiveModule.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface IntroduceViewController ()<WKUIDelegate,WKNavigationDelegate>

@end

@implementation IntroduceViewController

- (void)dealloc {
    NSLog(@"webViewController::dealloc()");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:NSStringFromClass([self.superclass class]) bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isShowTaBar= YES;
    self.isFirstProgram = YES;
    
//    if (@available(iOS 11, *)) {
//     self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    // webview请求url
    NSString *webSiteUrl = self.bannerUrl;
    self.requestUrl = webSiteUrl;
    
    self.title = self.titleStr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
