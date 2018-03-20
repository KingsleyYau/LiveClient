//
//  LiveService.m
//  livestream
//
//  Created by Max on 2017/10/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveService.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

static LiveService *gService = nil;
@implementation LiveService
#pragma mark - 获取实例
+ (instancetype)service {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gService) {
            gService = [[LiveService alloc] init];
        }
    });
    return gService;
}

- (id)init {
    NSLog(@"LiveService::init()");
    if (self = [super init]) {
    }
    return self;
}

- (NSString *)getServiceName {
    NSString *serviceName = @"live";
    NSLog(@"LiveService::getServiceName( serviceName : %@ )", serviceName);
    return serviceName;
}

- (NSString *)getServiceConflict {
    return @"live module tips";
}

- (void)openUrl:(NSURL *)url fromVC:(UIViewController *)fromVC {
    // 跳转到指定界面
    NSLog(@"LiveService::openUrl( url : %@, fromVC : %@ )", url, fromVC);
    
    // 记录入口
    [LiveModule module].fromVC = fromVC;
    
    // 记录需要处理的URL
    [LiveUrlHandler shareInstance].url = url;
    
    // 先跳转到主界面
    UIViewController *moduleVC = [LiveModule module].moduleVC;
    if ( !moduleVC.navigationController ) {
        // 还没进入直播模块, 由外部进入
        NSLog(@"LiveService::openUrl( [还没进入直播模块, 进入到主界面], url : %@, fromVC : %@ )", url, fromVC);
        [fromVC.navigationController pushViewController:moduleVC animated:NO];
        
    } else {
        // 已经进入直播模块
        NSLog(@"LiveService::openUrl( [已经进入直播模块, 已经在主界面, 解析URL], url : %@, fromVC : %@ )", url, fromVC);
        
        // 弹出到直播主界面
        UIViewController *vc = moduleVC.navigationController.topViewController;
        [vc dismissViewControllerAnimated:NO completion:nil];
        [moduleVC.navigationController popToViewController:moduleVC animated:NO];
        
        // 手动调用一次, 避免主界面viewWillAppear不调用
        [[LiveUrlHandler shareInstance] handleOpenURL];
    }
}

- (BOOL)isStopService:(NSURL *)url {
    NSLog(@"LiveService::isStopService( url : %@ )", url);
    return NO;
}

- (void)stopService {
    // 停止服务
    NSLog(@"LiveService::stopService()");
    
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
    NSLog(@"LiveService::openUrlByLive( url : %@ )", url);
    
    if (url.absoluteString.length > 0) {
        [self openUrl:url fromVC:[LiveModule module].fromVC];
    }
}

- (void)startService {
    NSLog(@"LiveService::startService()");
    
    // 内部开启互斥服务
    if ([LiveModule module].serviceManager) {
        [[LiveModule module].serviceManager startService:self];
    }
}

- (void)closeService {
    NSLog(@"LiveService::closeService()");
    
    // 内部注销互斥服务
    if ([LiveModule module].serviceManager) {
        [[LiveModule module].serviceManager stopService:self];
    }
}

@end
