//
//  LiveMutexService.m
//  livestream
//
//  Created by Max on 2017/10/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveMutexService.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveGobalManager.h"

static LiveMutexService *gService = nil;
@implementation LiveMutexService
#pragma mark - 获取实例
+ (instancetype)service {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gService) {
            gService = [[LiveMutexService alloc] init];
        }
    });
    return gService;
}

- (id)init {
    NSLog(@"LiveMutexService::init()");
    if (self = [super init]) {
    }
    return self;
}

- (NSString *)serviceName {
    NSString *serviceName = @"live";
    NSLog(@"LiveMutexService::serviceName( serviceName : %@ )", serviceName);
    return serviceName;
}

- (NSString *)serviceConflictTips {
    return @"Are you sure to leave the broadcast room?";
}

- (BOOL)handleOpenURL:(NSURL *)url fromVC:(UIViewController *)fromVC {
    // 跳转到指定界面
    NSLog(@"LiveMutexService::handleOpenURL( url : %@, fromVC : %@ )", url, fromVC);
    BOOL bFlag = YES;
    
    // 记录入口
    [LiveModule module].fromVC = fromVC;
    
    // 记录需要处理的URL
    [LiveUrlHandler shareInstance].url = url;
    
    // 先跳转到主界面
    UIViewController *moduleVC = [LiveModule module].moduleVC;
    if ( !moduleVC.navigationController ) {
        // 还没进入直播模块, 由外部进入
        NSLog(@"LiveMutexService::handleOpenURL( [还没进入直播模块, 进入到主界面], url : %@, fromVC : %@ )", url, fromVC);
        [fromVC.navigationController pushViewController:moduleVC animated:NO];
        
    } else {
        // 已经进入直播模块
        NSLog(@"LiveMutexService::handleOpenURL( [已经进入直播模块, 已经在主界面, 解析URL], url : %@, fromVC : %@ )", url, fromVC);
        
        // 弹出到直播主界面
        UIViewController *vc = moduleVC.navigationController.topViewController;
        [vc dismissViewControllerAnimated:NO completion:nil];
        [moduleVC.navigationController popToViewController:moduleVC animated:NO];
        
        // 手动调用一次, 避免主界面viewWillAppear不调用
        [[LiveUrlHandler shareInstance] handleOpenURL];
    }
    
    return bFlag;
}

- (BOOL)isStopService:(NSURL *)url {
    NSLog(@"LiveMutexService::isStopService( url : %@ )", url);
    if ([LiveGobalManager manager].liveRoom) {
        return YES;
    }
    return NO;
}

- (void)stopService {
    // 停止服务
    NSLog(@"LiveMutexService::stopService( [Live互斥服务停止] )");
    
    if ([LiveGobalManager manager].liveRoom) {
         [[LSImManager manager] leaveRoom:[LiveGobalManager manager].liveRoom.roomId];
    }

    // 强制关闭过渡和直播间界面
    UIViewController *moduleVC = [LiveModule module].moduleVC;
    if (moduleVC && moduleVC.navigationController ) {
        UIViewController *vc = moduleVC.navigationController.topViewController;
        [vc dismissViewControllerAnimated:NO completion:nil];
        
        // 退出其他导航栏界面
        if ([LiveModule module].fromVC) {
            // 从其他界面推进
            [moduleVC.navigationController popToViewController:[LiveModule module].fromVC animated:NO];
            
        } else {
            // 直接显示
            [moduleVC.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    
    @synchronized(self) {
        // 清除入口
        [LiveModule module].fromVC = nil;
    }
}

#pragma mark - 模块内部调用
- (void)openUrlByLive:(NSURL *)url {
    NSLog(@"LiveMutexService::openUrlByLive( url : %@ )", url);
    
    if ([LiveModule module].serviceManager && url.absoluteString.length > 0) {
        [[LiveModule module].serviceManager handleOpenURL:url];
    }
}

- (void)startService {
    NSLog(@"LiveMutexService::startService()");
    
    // 内部开启互斥服务
    if ([LiveModule module].serviceManager) {
        [[LiveModule module].serviceManager startService:self];
    }
}

- (void)closeService {
    NSLog(@"LiveMutexService::closeService()");
    
    // 内部注销互斥服务
    if ([LiveModule module].serviceManager) {
        [[LiveModule module].serviceManager stopService:self];
    }
}

@end
