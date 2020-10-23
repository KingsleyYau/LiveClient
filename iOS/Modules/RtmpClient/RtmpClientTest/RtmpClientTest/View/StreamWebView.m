//
//  StreamWebView.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/12.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamWebView.h"

@implementation StreamWebView

- (instancetype)initWithCoder:(NSCoder *)coder {
    CGRect frame = [UIScreen mainScreen].bounds;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    config.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = NO;
    }
    config.allowsAirPlayForMediaPlayback = YES;
    // 追加
//    config.applicationNameForUserAgent = @"curl/7.64.1";
    self = [super initWithFrame:frame configuration:config];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    // 覆盖
    self.customUserAgent = @"curl/7.64.1";
    return self;
}

@end
