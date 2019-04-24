//
//  LSWKWebViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "IntroduceView.h"

@interface LSWKWebViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTopDistance;

@property (nonatomic, assign) BOOL isShowTaBar;

@property (nonatomic, assign) BOOL isFirstProgram;

@property (nonatomic, copy) NSString *requestUrl;
// webview是否加载完成
@property (nonatomic, assign) BOOL didFinshNav;

- (void)setupRequestWebview;

- (void)setupIsResume:(BOOL)isResume;

- (void)webViewLoadingFinshCallBack;
@end
