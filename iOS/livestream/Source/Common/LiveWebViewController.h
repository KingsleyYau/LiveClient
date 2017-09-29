//
//  LiveWebViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface LiveWebViewController : KKViewController

@property (strong, nonatomic) UIWebView *webView;

- (void)requestHttp:(NSURLRequest *)request;

@end
