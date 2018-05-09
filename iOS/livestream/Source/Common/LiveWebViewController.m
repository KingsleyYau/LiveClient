//
//  LiveWebViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveWebViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "IntroduceView.h"
#import "LSLiveWKWebViewController.h"
#import "LiveModule.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface LiveWebViewController ()

@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation LiveWebViewController
- (void)dealloc {
    NSLog(@"LiveWebViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = self.isIntimacy;

    NSString *intimacyUrl; // 拼接url
    NSString *appVer = [NSString stringWithFormat:@"appver=%@",[LiveModule module].appVerCode];
    NSString *anchorID = [NSString stringWithFormat:@"&anchorid=%@",self.anchorId];
    NSString *device; // 设备类型
    if (IS_IPAD) {
        device = [NSString stringWithFormat:@"device=32"];
    } else {
        device = [NSString stringWithFormat:@"device=31"];
    }
    
    if (self.isIntimacy) {
        NSString *webSiteUrl = self.urlController.configManager.item.intimacy;
        if (webSiteUrl.length > 0) {
            if ([webSiteUrl containsString:@"?"]) {
                intimacyUrl = [NSString stringWithFormat:@"%@&%@&%@%@",webSiteUrl,device,appVer,anchorID];
            } else {
                intimacyUrl = [NSString stringWithFormat:@"%@?%@&%@%@",webSiteUrl,device,appVer,anchorID];
            }
        }
    } else {
        intimacyUrl = self.url;
        if (_isUserProtocol) {
            if ([intimacyUrl containsString:@"?"]) {
                intimacyUrl = [NSString stringWithFormat:@"%@&%@%@",intimacyUrl,device,appVer];
            } else {
                intimacyUrl = [NSString stringWithFormat:@"%@?%@%@",intimacyUrl,device,appVer];
            }
        }else {
            if ([intimacyUrl containsString:@"?"]) {
                intimacyUrl = [NSString stringWithFormat:@"%@&%@",intimacyUrl,appVer];
            } else {
                intimacyUrl = [NSString stringWithFormat:@"%@?%@&%@%@",intimacyUrl,device,appVer,anchorID];
            }
        }

    }
    self.urlController.baseUrl = intimacyUrl;

}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
//    self.edgesForExtendedLayout = UIRectEdgeNone;

    if (!self.viewDidAppearEver) {
        self.urlController.liveWKWebView = self.webView;
        self.urlController.controller = self;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = self.isIntimacy;
        [self.urlController requestWebview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
}

@end
