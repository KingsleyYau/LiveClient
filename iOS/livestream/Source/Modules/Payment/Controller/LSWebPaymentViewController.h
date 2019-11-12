//
//  LSWebPaymentViewController.h
//  livestream
//
//  Created by test on 2019/10/16.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSWKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSWebPaymentViewController : LSGoogleAnalyticsViewController
/** 订单号 */
@property (nonatomic, copy) NSString *orderNo;

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

NS_ASSUME_NONNULL_END
