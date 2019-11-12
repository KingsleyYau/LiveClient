//
//  CommonWebView.m
//  dating
//
//  Created by test on 2018/3/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSCommonWebView.h"

@implementation LSCommonWebView


- (instancetype)initWithCoder:(NSCoder *)coder{
    
    CGRect frame = CGRectMake(0, 0, 200, 300);
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc] init];
    //    在ios11上设置这属性可能会导致网页显示不全
//    myConfiguration.preferences.minimumFontSize = 10;
    myConfiguration.preferences.javaScriptEnabled = YES;
    myConfiguration.allowsInlineMediaPlayback = YES;
    myConfiguration.mediaPlaybackRequiresUserAction = NO;
    myConfiguration.mediaPlaybackAllowsAirPlay = YES;
    

    self.backgroundColor = [UIColor clearColor];
    
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
 
    
}


@end
