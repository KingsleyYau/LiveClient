//
//  AnchorPersonalViewController.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPersonalViewController.h"

#import "PreLiveViewController.h"

#import "MeLevelViewController.h"
#import "LSLiveWKWebViewController.h"
#import "LSLiveGuideViewController.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface AnchorPersonalViewController ()<LSLiveGuideViewControllerDelegate>

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation AnchorPersonalViewController

- (void)dealloc {
    NSLog(@"AnchorPersonalViewController::dealloc()");
    [self.personalView stopLoading];
    [self.personalView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11, *)) {
        self.personalView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = NO;
    self.urlController.isRequestWeb = YES;
    
    NSString *anchorPage = self.urlController.configManager.item.anchorPage;
    NSString *device; // 设备类型
    NSString *anchorid = [NSString stringWithFormat:@"anchorid=%@",self.anchorId]; // 主播id;
    NSString *enterroom = [NSString stringWithFormat:@"&enterroom=%d",self.enterRoom];
    if (anchorPage.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        if ([anchorPage containsString:@"?"]) {
            anchorPage = [NSString stringWithFormat:@"%@&%@&%@%@",anchorPage,device,anchorid,enterroom];
        } else {
            anchorPage = [NSString stringWithFormat:@"%@?%@&%@%@",anchorPage,device,anchorid,enterroom];
        }
    }
    self.urlController.baseUrl = anchorPage;
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView{
    [super setupContainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (!self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = YES;
    }
    //    else {
    //
    //    }
    //    [self.navigationController setNavigationBarHidden:NO];
    //    self.urlController.liveWKWebView = self.personalView;
    //    self.urlController.controller = self;
    //    [self.urlController requestWebview];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        LSLiveGuideViewController *guide =  [[LSLiveGuideViewController alloc] initWithNibName:nil bundle:nil];
        guide.listGuide = NO;
        guide.guideDelegate = self;
        [self addChildViewController:guide];
        [self.view addSubview:guide.view];
        [guide.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        // 使约束生效
        [guide.view layoutSubviews];
        [self hideAndResetLoading];
    }else{
        if (!self.viewDidAppearEver) {
            self.urlController.liveWKWebView = self.personalView;
            self.urlController.controller = self;
            self.urlController.isShowTaBar = NO;
            self.urlController.isRequestWeb = YES;
            [self.urlController requestWebview];
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
//    [self.navigationController setNavigationBarHidden:NO];
    
        self.navigationController.navigationBar.hidden = NO;
}

- (void)lsLiveGuideViewControllerDidFinishGuide:(LSLiveGuideViewController *)guideViewController {
    //TODO:新手引导页退出导航栏操作
    //    self.navigationController.navigationBar.hidden = YES;
    
    
    if (@available(iOS 11, *)) {
        self.personalView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [guideViewController.view removeFromSuperview];
    
    self.urlController.liveWKWebView = self.personalView;
    self.urlController.controller = self;
    self.urlController.isShowTaBar = NO;
    self.urlController.isRequestWeb = YES;
    [self.urlController requestWebview];
}
@end
