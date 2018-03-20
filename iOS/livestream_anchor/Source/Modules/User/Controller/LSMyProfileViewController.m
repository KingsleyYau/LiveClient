//
//  LSMyProfileViewController.m
//  livestream_anchor
//
//  Created by test on 2018/3/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMyProfileViewController.h"
#import "LSLiveWKWebViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
@interface LSMyProfileViewController ()
@property (nonatomic, strong) LSLiveWKWebViewController *urlController;
@end

@implementation LSMyProfileViewController



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.urlController.liveWKWebView = self.profileView;
    self.urlController.controller = self;
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;
    // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    [self.urlController requestWebview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        self.profileView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isRequestWeb = YES;
    
    NSString *anchorPage = self.urlController.configManager.item.mePageUrl;
    NSString *device; // 设备类型
    if (anchorPage.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        
    }
    self.urlController.baseUrl = anchorPage;
}
@end
