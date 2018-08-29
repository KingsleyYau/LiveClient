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




@interface AnchorPersonalViewController ()

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;

@end

@implementation AnchorPersonalViewController

- (void)dealloc {
    NSLog(@"AnchorPersonalViewController::dealloc()");
    [self.personalView stopLoading];
    [self.personalView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveAnchorApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11, *)) {
        self.personalView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;
    
   
    NSString *anchorPage = self.urlController.configManager.item.manPageUrl;
    anchorPage = [self.urlController setupCommonConfig:anchorPage];
    NSString *anchorid = [NSString stringWithFormat:@"manid=%@",self.anchorId]; // 主播id;
    NSString *showinvite = [NSString stringWithFormat:@"&showinvite=%d",self.showInvite];
     anchorPage = [NSString stringWithFormat:@"%@&%@%@",anchorPage,anchorid,showinvite];
//    if (anchorPage.length > 0) {

//        if ([anchorPage containsString:@"?"]) {
//            anchorPage = [NSString stringWithFormat:@"%@&%@&%@%@",anchorPage,device,anchorid,showinvite];
//        } else {
//            anchorPage = [NSString stringWithFormat:@"%@?%@&%@%@",anchorPage,device,anchorid,showinvite];
//        }
//    }
    self.urlController.baseUrl = anchorPage;
}


- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    UIView *barBackgroundView = [[self.navigationController.navigationBar subviews] objectAtIndex:0];
    UIImageView *backgroundImageView = [[barBackgroundView subviews] objectAtIndex:0];
    if (self.navigationController.navigationBar.isTranslucent) {
        if (backgroundImageView != nil && backgroundImageView.image != nil) {
            barBackgroundView.alpha = alpha;
        } else {
            UIView *backgroundEffectView = [[barBackgroundView subviews] objectAtIndex:1];
            if (backgroundEffectView != nil) {
                backgroundEffectView.alpha = alpha;
            }
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
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
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        self.urlController.liveWKWebView = self.personalView;
        self.urlController.controller = self;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = YES;
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
        [self.urlController requestWebview];
    }
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self setNeedsNavigationBackground:0];
    [self hideNavgationBarBottomLine:YES];
    
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    [self setNeedsNavigationBackground:1];
    [self hideNavgationBarBottomLine:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}



@end
