//
//  AnchorPersonalView.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPersonalView.h"

@implementation AnchorPersonalView 

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc] init];
    
    
    myConfiguration.preferences.minimumFontSize = 10;
    
    myConfiguration.preferences.javaScriptEnabled = YES;
    
    //通过JS与webView内容交互
    myConfiguration.userContentController = [WKUserContentController new];
    //注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    [myConfiguration.userContentController addScriptMessageHandler:self name:@"LiveApp"];
    
    
    
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    //    if ([self.delegate respondsToSelector:@selector(hx_userContentController:didReceiveScriptMessage:)]) {
    //        HXWebModel *messageModel = [[HXWebModel alloc] init];
    //        messageModel.name = message.name;
    //        messageModel.body = message.body;
    //        [self.delegate hx_userContentController:userContentController didReceiveScriptMessage:messageModel];
    //    }
}

@end
