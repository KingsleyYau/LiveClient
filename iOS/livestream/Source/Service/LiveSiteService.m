//
//  LiveSiteService.m
//  livestream
//
//  Created by Max on 2018/9/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveSiteService.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

#import "LSRequestManager.h"
#import "LSGetTokenRequest.h"

@interface LiveSiteService ()
// 站点Id
@property (strong) NSString *siteId;
// 站点web接口域名
@property (strong) NSString *webSiteUrl;
// 站点app接口域名
@property (strong) NSString *appSiteUrl;
// 站点msite接口域名
@property (strong) NSString *wapSiteUrl;
@end

@implementation LiveSiteService

- (void)initSite:(NSString *)siteId webSiteUrl:(NSString *)webSiteUrl appSiteUrl:(NSString *)appSiteUrl wapSiteUrl:(NSString *)wapSiteUrl {
    NSLog(@"LiveSiteService::initSite:( [初始化站点切换服务], siteId : %@, webSiteUrl : %@, appSiteUrl : %@, wapSiteUrl : %@ )", siteId, webSiteUrl, appSiteUrl, wapSiteUrl);

    _siteId = siteId;
    _webSiteUrl = webSiteUrl;
    _appSiteUrl = appSiteUrl;
    _wapSiteUrl = wapSiteUrl;

    LSRequestManager *manager = [LSRequestManager manager];
    [manager setConfigWebSite:webSiteUrl];
}

- (void)activeSite {
    NSLog(@"LiveSiteService::activeSite:( [激活站点], siteId : %@, webSiteUrl : %@, appSiteUrl : %@, wapSiteUrl : %@ )", _siteId, _webSiteUrl, _appSiteUrl, _wapSiteUrl);
}

- (void)inactiveSite {
    NSLog(@"LiveSiteService::inactiveSite:( [停止站点], siteId : %@, webSiteUrl : %@, appSiteUrl : %@, wapSiteUrl : %@ )", _siteId, _webSiteUrl, _appSiteUrl, _wapSiteUrl);
    
    // 释放主界面
    [[LiveModule module] destroyModuleVC];
    
    // 清空外部链接跳转处理
    [LiveUrlHandler shareInstance].delegate = nil;
    [LiveUrlHandler shareInstance].parseDelegate = nil;
}

- (void)changeSite:(NSString *)siteId local:(BOOL)local handler:(AppChangeSitehHandler)handler {
    if (local) {
        // 切换站点接口
        NSLog(@"LiveSiteService::changeSite:( [切换站点, 本地切换], siteId : %@ )", siteId);

        if (handler) {
            handler(YES, @"", @"", nil);
        }

    } else {
        NSLog(@"LiveSiteService::changeSite:( [切换站点, 请求获取站点通用Token接口] )");

        LSGetTokenRequest *request = [[LSGetTokenRequest alloc] init];
        HTTP_OTHER_SITE_TYPE siteIdType = [[LSRequestManager manager] getHttpSiteTypeByServerSiteId:siteId];
        request.siteId = siteIdType;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull memberId, NSString * _Nonnull sid) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"LiveSiteService::changeSite:( [切换站点, 请求获取站点通用Token接口, %@], errnum : %d, errmsg : %@, siteId : %@, token : %@ )", BOOL2SUCCESS(success), errnum, errmsg, siteId, sid);
                if (success) {
                }
                
                // 回调
                if (handler) {
                    handler(success, [NSString stringWithFormat:@"%d", errnum], errmsg, sid);
                }
            });
        };
        
        BOOL bFlag = [[LSSessionRequestManager manager] sendRequest:request];
        if (!bFlag) {
            NSLog(@"LiveSiteService::changeSite:( [请求获取站点通用Token, Fail], siteId : %@ )", siteId);
            if (handler) {
                handler(NO, @"", NSLocalizedStringFromSelf(@"Error_Request_Token"), nil);
            }
        }
    }
}

- (void)cleanCookies {
    [[LSRequestManager manager] cleanCookies];
}
@end
