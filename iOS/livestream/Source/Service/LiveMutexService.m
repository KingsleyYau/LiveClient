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
#import "LSImManager.h"
#import "LSMinLiveManager.h"
static LiveMutexService *gService = nil;
@interface LiveMutexService () {
    NSString *_siteId;
}
@end

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
    return @"To continue this operation, you need to leave the current broadcast room. Are you sure?";
}

- (void)setSiteId:(NSString *)siteId {
    _siteId = siteId;
}

- (BOOL)handleOpenURL:(NSURL *)url fromVC:(UIViewController *)fromVC {
    // 跳转到指定界面
    NSLog(@"LiveMutexService::handleOpenURL( url : %@, fromVC : %@ )", url, fromVC);
    BOOL bFlag = YES;

    // 打开URL
    [[LiveUrlHandler shareInstance] handleOpenURL:url];

    return bFlag;
}

- (BOOL)isStopService:(NSURL *)url siteId:(NSString *)siteId {
    BOOL bFlag = NO;
    NSLog(@"LiveMutexService::isStopService( url : %@, siteId : %@, Current roomId : %@ )", url, siteId, [LiveGobalManager manager].liveRoom.roomId);
    
    // 处理链接
    LSUrlParmItem *item = [[LiveUrlHandler shareInstance] parseUrlParms:url];

        // 如果在直播间
        if ( [LiveGobalManager manager].liveRoom ) {
            if( ((siteId.length > 0) && ![siteId isEqualToString:_siteId]) ) {
                // 站点不相同
                bFlag = YES;
            } else {
                if ([LiveGobalManager manager].liveRoom.userId.length > 0 && [item.anchorId isEqualToString:[LiveGobalManager manager].liveRoom.userId]) {
                    switch (item.roomType) {
                        case LiveUrlRoomTypePublic:{
                            if ([LiveGobalManager manager].liveRoom.roomType != LiveRoomType_Public) {
                                bFlag = YES;
                            }
                        }break;
                        case LiveUrlRoomTypePrivate: {
//                            if ([LiveGobalManager manager].liveRoom.roomType != LiveRoomType_Private) {
                                bFlag = YES;
//                            }
                        }break;
                        case LiveUrlRoomTypePrivateInvite:{
//                            if ([LiveGobalManager manager].liveRoom.roomType != LiveRoomType_Private) {
                                bFlag = YES;
//                            }
                        }break;
                        case LiveUrlRoomTypePrivateAccept: {
//                            if ([LiveGobalManager manager].liveRoom.roomType != LiveRoomType_Private) {
                            bFlag = YES;
//                            }
                        }break;
                            
                        default:
                            break;
                    }
                    if (item.roomId.length > 0) {
                        bFlag = YES;
                    }
                }else {
                    switch (item.type) {

                        case LiveUrlTypeLiveRoom:{
                            bFlag = YES;
                        }
                        default:
                            break;
                    }
                }
                
                

            }
        }
        
    
    

    return bFlag;
}

- (void)stopService {
    // 停止服务
    NSLog(@"LiveMutexService::stopService( [Live互斥服务停止] )");

    if ([LiveGobalManager manager].liveRoom) {
        [[LSMinLiveManager manager] minLiveViewDidCloseBtn];
        [[LSImManager manager] leaveRoom:[LiveGobalManager manager].liveRoom];
    }

    // 强制关闭过渡和直播间界面
    [[LiveGobalManager manager] dismissLiveRoomVC];
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
