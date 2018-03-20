//
//  UserAgreementViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserAgreementViewController.h"
#import "IntroduceView.h"
#import "LSLiveWKWebViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface UserAgreementViewController () <WKUIDelegate,WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation UserAgreementViewController

- (void)dealloc {
    NSLog(@"UserAgreementViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.isTermsOfUse?NSLocalizedString(@"Terms and Conditions", nil):NSLocalizedString(@"Privacy Policy", nil);
    
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;
    [self.urlController clearAllCookies];
    NSString *webSiteUrl = @"";
    //NSString *webSiteUrl = self.isTermsOfUse?self.urlController.configManager.item.termsOfUse:
    //self.urlController.configManager.item.privacyPolicy;
    NSString *device; // 设备类型
    if (webSiteUrl.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        if ([webSiteUrl containsString:@"?"]) {
            webSiteUrl = [NSString stringWithFormat:@"%@&%@",webSiteUrl,device];
        } else {
            webSiteUrl = [NSString stringWithFormat:@"%@?%@",webSiteUrl,device];
        }
    }
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
//    [self.navigationController setNavigationBarHidden:YES];
//    self.navigationController.navigationBar.hidden = YES;
    if (!self.viewDidAppearEver) {
        self.urlController.liveWKWebView = self.webView;
        self.urlController.controller = self;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = YES;
        [self.urlController requestWebview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
//    [self.navigationController setNavigationBarHidden:NO];
//    self.navigationController.navigationBar.hidden = NO;
}


@end
