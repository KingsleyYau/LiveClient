//
//  IntroduceView.m
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IntroduceView.h"
// js调用OC的类名
#define LIVEAPP_JS @"LiveApp"
// js回调的函数名
#define LVIEAPP_CALLBACK @"CallBack"
// js回调的函数名是callbackAppGAEvent
#define LIVEAPP_CALLBACK_APPGAEVENT @"callbackAppGAEvent"
#define LIVEAPP_CALLBACK_APPGAEVENT_EVENT @"Event"
#define LIVEAPP_CALLBACK_APPPUBLICGAEVENT_EVENT @"event"
#define LIVEAPP_CALLBACK_APPPUBLICGAEVENT_CATEGORY @"category"
#define LIVEAPP_CALLBACK_APPPUBLICGAEVENT_LABEL @"label"
// js回调的函数名是callbackAppCloseWebView
#define LIVEAPP_CALLBACK_APPCLOSEWEBVIEW @"callbackAppCloseWebView"
// js回调的函数名是callbackWebReload
#define LIVEAPP_CALLBACK_WEBRELOAD @"callbackWebReload"
#define LIVEAPP_CALLBACK_WEBRELOAD_ERROR @"Errno"
//身份验证失败
#define LIVEAPP_CALLBACK_AUTH_EXPIRED @"callbackWebAuthExpired"
//账号余额不足
#define LIVEAPP_CALLBACK_RECHANGE @"callbackWebRechange"
// 节目GA回调
#define LIVEAPP_CALLBACK_APPPUBLiCGAEVENT @"callbackAppPublicGAEvent"
// app调用界面回到前台JS接口
#define LIVEAPP_TRANSFER_NOTIFYRESUME @"notifyResume()"

@interface IntroduceView()<WKScriptMessageHandler>

@end


@implementation IntroduceView


- (instancetype)initWithCoder:(NSCoder *)coder{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc] init];
    
    
    myConfiguration.preferences.minimumFontSize = 10;
    
    myConfiguration.preferences.javaScriptEnabled = YES;
    myConfiguration.allowsInlineMediaPlayback = YES;
    myConfiguration.mediaPlaybackRequiresUserAction = NO;
    myConfiguration.mediaPlaybackAllowsAirPlay = YES;
    
    // 加载LiveApp.js的LiveApp类 WKUserScriptInjectionTimeAtDocumentStart在加载网页前插入js的 WKUserScriptInjectionTimeAtDocumentEnd在网页加载完成后才加入
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[IntroduceView getJsString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    
    //通过JS与webView内容交互
    myConfiguration.userContentController = [[WKUserContentController alloc] init];
    [myConfiguration.userContentController addUserScript:usrScript];
    //注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    [myConfiguration.userContentController addScriptMessageHandler:self name:LIVEAPP_JS];
    
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

// 将js文件变成NSString（里面就是LiveApp类的js，为了将这个js文件加载进web去，js才能调用OC）
+ (NSString*)getJsString {
    NSString *path =[[LiveBundle bundleForClass:[self class]] pathForResource:LIVEAPP_JS ofType:@"js"];
    NSString *handlerJS = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingUTF8 error:nil];
    handlerJS = [handlerJS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return handlerJS;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    // 判断是否是LiveApp类
    if ([message.name isEqualToString:LIVEAPP_JS]) {
        // 得到回调的函数名
        NSString *methodName = message.body[LVIEAPP_CALLBACK];
        // 判断是否是回调callbackAppGAEvent函数
        if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPGAEVENT]) {
            NSString *event = message.body[LIVEAPP_CALLBACK_APPGAEVENT_EVENT];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackAppGAEvent:)]) {
                [self.webViewJSDelegate webViewJSCallbackAppGAEvent:event];
            }
        }
        // 判断是否是回调callbackAppCloseWebView函数
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPCLOSEWEBVIEW]) {
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackAppCloseWebView)]) {
                [self.webViewJSDelegate webViewJSCallbackAppCloseWebView];
            }
        }
        // 判断是否是回调callbackWebReload函数
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_WEBRELOAD]) {
            NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackWebReload:)]) {
                [self.webViewJSDelegate webViewJSCallbackWebReload:error];
            }
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_AUTH_EXPIRED]) {
            //身份验证失败
             NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallBackTokenTimeOut:)]) {
                [self.webViewJSDelegate webViewJSCallBackTokenTimeOut:error];
            }
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_RECHANGE]) {
            NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            //账号余额不足
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallBackAddCredit:)]) {
                [self.webViewJSDelegate webViewJSCallBackAddCredit:error];
            }
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPPUBLiCGAEVENT]) {
            //节目GA跟踪
            NSString *category = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_CATEGORY];
            NSString *event = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_EVENT];
            NSString *label = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_LABEL];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackAppPublicGAEvent:category:label:)]) {
                [self.webViewJSDelegate webViewJSCallbackAppPublicGAEvent:event category:category label:label];
            }
        }
    }
}

#pragma mark - app调用JS接口
- (void)webViewTransferResumeHandler:(JSFinshHandler)handler {
    [self webViewTransferJSName:LIVEAPP_TRANSFER_NOTIFYRESUME handler:^(id  _Nullable response, NSError * _Nullable error) {
        NSLog(@"IntroduceView::webViewTransferResumeHandler ([调用js界面回到前台事件, response : %@, error : %@])",response ,error);
        handler(response, error);
    }];
}

- (void)webViewTransferJSName:(NSString *)jsName handler:(JSFinshHandler)handler {
    [self evaluateJavaScript:jsName completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        handler(response, error);
    }];
}

@end
