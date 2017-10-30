//
//  LiveWebViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveWebViewController.h"

@interface LiveWebViewController () <UIWebViewDelegate>

@end

@implementation LiveWebViewController
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupContainView {
}

- (void)requestHttp:(NSURLRequest *)request {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:self.webView];

    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"web 加载完成");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"web 加载错误 %@", error);
}

@end
