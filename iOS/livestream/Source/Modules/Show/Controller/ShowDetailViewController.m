//
//  ShowDetailViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "LSLiveWKWebViewController.h"
#import "LiveModule.h"
#import "ShowAddCreditsView.h"
#import "AnchorPersonalViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
@interface ShowDetailViewController ()<WKUIDelegate,WKNavigationDelegate,WebViewJSDelegate>
// 内嵌web
@property (weak, nonatomic) IBOutlet IntroduceView *detailView;

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation ShowDetailViewController

- (void)dealloc {
    NSLog(@"ShowDetailViewController::dealloc()");
    [self.detailView stopLoading];
    [self.detailView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Show";
    
    if (@available(iOS 11, *)) {
        self.detailView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.detailView.webViewJSDelegate = self;
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;
    
    NSString *webSiteUrl = self.urlController.configManager.item.showDetailPage;
    NSString *appVer = [NSString stringWithFormat:@"appver=%@",[LiveModule module].appVerCode];
    NSString *device; // 设备类型
    if (webSiteUrl.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        if ([webSiteUrl containsString:@"?"]) {
            webSiteUrl = [NSString stringWithFormat:@"%@&%@%@",webSiteUrl,device,appVer];
        } else {
            webSiteUrl = [NSString stringWithFormat:@"%@?%@%@",webSiteUrl,device,appVer];
        }
    }
    
    webSiteUrl = [NSString stringWithFormat:@"%@&live_show_id=%@",webSiteUrl,self.item.showLiveId];
    
    self.urlController.baseUrl = webSiteUrl;
}


- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)setupContainView{
    [super setupContainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    if (!self.viewDidAppearEver) {
        self.urlController.liveWKWebView = self.detailView;
        self.urlController.controller = self;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = YES;
        [self.urlController requestWebview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
}

- (void)getTicket {
    
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)WatchNow {
    
}

- (void)pushLadyDetail
{
    AnchorPersonalViewController * vc = [[AnchorPersonalViewController alloc]initWithNibName:nil bundle:nil];
    vc.anchorId = self.item.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
