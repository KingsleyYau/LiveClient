//
//  IntroduceView.m
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IntroduceView.h"
// js调用OC的类名
#define LIVEAPP_JS @"LiveAnchorApp"
// js回调的函数名
#define LVIEAPP_CALLBACK @"CallBack"
// js回调的函数名是callbackAppGAEvent
#define LIVEAPP_CALLBACK_APPGAEVENT @"callbackAppGAEvent"
#define LIVEAPP_CALLBACK_APPGAEVENT_EVENT @"Event"
// js回调的函数名是callbackAppCloseWebView
#define LIVEAPP_CALLBACK_APPCLOSEWEBVIEW @"callbackAppCloseWebView"
// js回调的函数名是callbackWebReload
#define LIVEAPP_CALLBACK_WEBRELOAD @"callbackWebReload"
#define LIVEAPP_CALLBACK_WEBRELOAD_ERROR @"Errno"
// js回调的函数名是callbackInvite
#define LIVEAPP_CALLBACK_INVITE @"callbackInvite"
#define LIVEAPP_CALLBACK_WEBRELOAD_USERID @"userid"
#define LIVEAPP_CALLBACK_WEBRELOAD_NAME @"name"
#define LIVEAPP_CALLBACK_WEBRELOAD_PHOTOURL @"photoUrl"
// js回调的函数名是callbackWebAuthExpired
#define LIVEAPP_CALLBACK_AUTHEXPIRED @"callbackWebAuthExpired"
#define LIVEAPP_CALLBACK_ERRMSG @"errmsg"


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
    
    // 加载LiveApp.js的LiveApp类
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[IntroduceView getJsString] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
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
    NSString *path =[[NSBundle bundleForClass:[self class]] pathForResource:LIVEAPP_JS ofType:@"js"];
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
            NSString *Errno = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackWebReload:)]) {
                [self.webViewJSDelegate webViewJSCallbackWebReload:Errno];
            }
        }else if ([methodName isEqualToString:LIVEAPP_CALLBACK_INVITE]) {
            NSString *userid = message.body[LIVEAPP_CALLBACK_WEBRELOAD_USERID];
            NSString *name = message.body[LIVEAPP_CALLBACK_WEBRELOAD_NAME];
            NSString *photoUrl = message.body[LIVEAPP_CALLBACK_WEBRELOAD_PHOTOURL];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackInvite:nickName:photo:)]) {
                [self.webViewJSDelegate webViewJSCallbackInvite:userid nickName:name photo:photoUrl];
            }
        }else if ([methodName isEqualToString:LIVEAPP_CALLBACK_AUTHEXPIRED]) {
                 NSString *errmsg = message.body[LIVEAPP_CALLBACK_ERRMSG];
            if ([self.webViewJSDelegate respondsToSelector:@selector(webViewJSCallbackWebAuthExpired:)]) {
                [self.webViewJSDelegate webViewJSCallbackWebAuthExpired:errmsg];
            }
        }
    }
    
}

@end
