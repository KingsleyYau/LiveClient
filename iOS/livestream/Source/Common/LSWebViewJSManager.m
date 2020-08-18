//
//  LSWebViewJSManager.m
//  livestream
//
//  Created by Randy_Fan on 2018/9/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSWebViewJSManager.h"
#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LSImManager.h"

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
#define LIVEAPP_CALLBACK_APPCLOSEWEBVIEW @"callbackCloseWebView"
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
#define LIVEAPP_SHOWNAVIGATION @"callbackShowNavigation"
#define LIVEAPP_ISSHOW @"is_show"


@interface LSWebViewJSManager ()<LoginManagerDelegate, LSListViewControllerDelegate, WKScriptMessageHandler>
/**
 重登陆管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;
@end

@implementation LSWebViewJSManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.loginManager = [LSLoginManager manager];
    }
    return self;
}

- (void)setWebViewUserScript:(IntroduceView *)webView {
    // 加载LiveApp.js的LiveApp类 WKUserScriptInjectionTimeAtDocumentStart在加载网页前
    // 插入js的WKUserScriptInjectionTimeAtDocumentEnd在网页加载完成后才加入
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[LSWebViewJSManager getJsString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:usrScript];
    //注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    [webView.configuration.userContentController addScriptMessageHandler:self name:LIVEAPP_JS];
}

- (void)removeWebViewUserScript:(IntroduceView *)webView {
    [webView.configuration.userContentController removeScriptMessageHandlerForName:LIVEAPP_JS];
}

// 将js文件变成NSString（里面就是LiveApp类的js，为了将这个js文件加载进web去，js才能调用OC）
+ (NSString*)getJsString {
    NSString *path =[[LiveBundle bundleForClass:[self class]] pathForResource:LIVEAPP_JS ofType:@"js"];
    NSString *handlerJS = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingUTF8 error:nil];
    handlerJS = [handlerJS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return handlerJS;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 判断是否是LiveApp类
    if ([message.name isEqualToString:LIVEAPP_JS]) {
        // 得到回调的函数名
        NSString *methodName = message.body[LVIEAPP_CALLBACK];
        // 判断是否是回调callbackAppGAEvent函数
        if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPGAEVENT]) {
            NSString *event = message.body[LIVEAPP_CALLBACK_APPGAEVENT_EVENT];
            [self webViewJSCallbackAppGAEvent:event];
        }
        // 判断是否是回调callbackAppCloseWebView函数
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPCLOSEWEBVIEW]) {
            [self webViewJSCallbackAppCloseWebView];
        }
        // 判断是否是回调callbackWebReload函数
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_WEBRELOAD]) {
            NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            [self webViewJSCallbackWebReload:error];
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_AUTH_EXPIRED]) {
            //身份验证失败
            NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            [self webViewJSCallBackTokenTimeOut:error];
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_RECHANGE]) {
            NSString *error = message.body[LIVEAPP_CALLBACK_WEBRELOAD_ERROR];
            //账号余额不足
            [self webViewJSCallBackAddCredit:error];
        }
        else if ([methodName isEqualToString:LIVEAPP_CALLBACK_APPPUBLiCGAEVENT]) {
            //节目GA跟踪
            NSString *category = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_CATEGORY];
             NSString *event = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_EVENT];
            NSString *label = message.body[LIVEAPP_CALLBACK_APPPUBLICGAEVENT_LABEL];
            [self webViewJSCallbackAppPublicGAEvent:event category:category label:label];
        }else if ([methodName isEqualToString:LIVEAPP_SHOWNAVIGATION]) {
            NSString *isShow = message.body[LIVEAPP_ISSHOW];
            [self webViewJsCallBackIsShowNavigation:isShow];
        }
    }
}

#pragma mark - 登录回调
// 登录回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(jsManagerOnLogin:)]) {
            [self.delegate jsManagerOnLogin:success];
        }
    });
}

#pragma mark - JS接口回调
// GA跟踪事件JS接口
- (void)webViewJSCallbackAppGAEvent:(NSString *)event {
    NSLog(@"WebViewJSCallbackAppGAEvent event:%@", event);
    [[LiveModule module].analyticsManager reportActionEvent:event eventCategory:EventCategoryBroadcast];
}

// 关闭当前WebView的JS接口
- (void)webViewJSCallbackAppCloseWebView {
    NSLog(@"WebViewJSCallbackAppCloseWebView");
    if ([self.delegate respondsToSelector:@selector(jsManagerCallbackCloseWebView)]) {
        [self.delegate jsManagerCallbackCloseWebView];
    }
}

// Web通知App页面加载失败
- (void)webViewJSCallbackWebReload:(NSString *)error {
    NSLog(@"WebViewJSCallbackWebReload error:%@", error);
    BOOL isReLoad = YES;
    if (error != nil &&error.length > 0) {
        int value = [error intValue];
        // 判断是否token过期，重新登录
        if (value == LCC_ERR_TOKEN_EXPIRE) {
            isReLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginManager logout:LogoutTypeKick msg:error];
            });
        }
    }
    if (isReLoad) {
        if ([self.delegate respondsToSelector:@selector(jsManagerCallbackWebReload)]) {
            [self.delegate jsManagerCallbackWebReload];
        }
    }
}

//token过期
- (void)webViewJSCallBackTokenTimeOut:(NSString *)error {
    NSLog(@"webViewJSCallBackTokenTimeOut error:%@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager logout:LogoutTypeKick msg:error];
    });
}

//账号余额不足
- (void)webViewJSCallBackAddCredit:(NSString *)error {
    NSLog(@"webViewJSCallBackAddCredit error:%@", error);
    if ([self.delegate respondsToSelector:@selector(jsManagerCallBackAddCredit:)]) {
        [self.delegate jsManagerCallBackAddCredit:error];
    }
}

//节目GA跟踪
- (void)webViewJSCallbackAppPublicGAEvent:(NSString *)event category:(NSString *)category label:(NSString *)label {
    NSLog(@"webViewJSCallbackAppPublicGAEvent event:%@ category:%@ label:%@", event,category,label);
    [[LiveModule module].analyticsManager reportActionEvent:event eventCategory:category label:label value:nil];
}

- (void)webViewJsCallBackIsShowNavigation:(NSString *)isShow {
    NSLog(@"webViewJsCallBackIsShowNavigation isShow:%@", isShow);
    if (isShow != nil && isShow.length > 0) {
        int showNav = [isShow intValue];
        if ([self.delegate respondsToSelector:@selector(jsManagerCallBackIsShowNavigation:)]) {
            [self.delegate jsManagerCallBackIsShowNavigation:showNav];
        }
    }
}

@end
