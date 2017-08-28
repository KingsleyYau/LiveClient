//
//  LiveModuleManager.m
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveModuleManager.h"
#import "GetLiveRoomHotListRequest.h"
#import "MainViewController.h"

@interface LiveModuleManager ()

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation LiveModuleManager

+ (instancetype)createLiveManager {
    
    static LiveModuleManager *liveManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 初始化登录管理器
        liveManager.loginManager = [LoginManager manager];
        
        // 初始化IM
        liveManager.imManager = [IMManager manager];
        
        // 初始化礼物下载管理器
        liveManager.giftDownloadManager = [LiveGiftDownloadManager giftDownloadManager];
    });
    
    return liveManager;
}


+ (void)setLiveRequestManager {
    
    // 设置接口管理类属性
    [RequestManager setLogEnable:YES];
    [RequestManager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
    
    RequestManager* manager = [RequestManager manager];
    [manager setWebSite:@"http://172.25.32.17:3007"];
    [manager setWebSiteUpload:@"http://172.25.32.17:82"];
}


+ (void)liveLoginToPhone:(NSString *)phone password:(NSString *)password areano:(NSString *)areano {
    
    // 调用登录
    [[LiveModuleManager createLiveManager].loginManager login:phone password:password areano:areano];
}


+ (void)pushToLivestreamWithController:(UIViewController *)controller {
    
    // 进入直播模块
    MainViewController* mainController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    [controller.navigationController pushViewController:mainController animated:YES];
    
    
}


@end
