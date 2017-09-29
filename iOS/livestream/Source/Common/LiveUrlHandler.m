//
//  LiveUrlHandler.m
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveUrlHandler.h"
#import "LoginManager.h"
static LiveUrlHandler* gInstance = nil;
@interface LiveUrlHandler()<LoginManagerDelegate>
/**
 *  是否已经被URL打开
 */
@property (assign, atomic) BOOL openByUrl;

/**
 *  是否有待处理URL
 */
@property (assign, atomic) BOOL hasHandle;

/** 代理数组 */
@property (nonatomic,strong) NSMutableArray *delegates;


@end


@implementation LiveUrlHandler
+ (instancetype)shareInstance {
    if( gInstance == nil ) {
        gInstance = [[[self class] alloc] init];
    }
    return gInstance;
}

- (id)init {
    if( self = [super init] ) {
        _openByUrl = NO;
        _type = LiveUrlTypeNone;
        self.hasHandle = NO;
        self.delegates = [NSMutableArray array];
        // 自动登陆
        [[LoginManager manager] addDelegate:self];
    }
    return self;
}

- (void)addDelegate:(id<LiveUrlHandlerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LiveUrlHandlerDelegate>)delegate {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LiveUrlHandlerDelegate> item = (id<LiveUrlHandlerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}


- (BOOL)handleOpenURL:(NSURL *)url {
    NSLog(@"URLHandler::handleOpenURL( url : %@ )", url);
    NSLog(@"URLHandler::handleOpenURL( url.host : %@ )", url.host);         
    NSLog(@"URLHandler::handleOpenURL( url.path : %@ )", url.path);
    NSLog(@"URLHandler::handleOpenURL( url.query : %@ )", url.query);
    
//    // 第一次进入通知GA,暂无GA
//    if( !_openByUrl ) {
//        _openByUrl = YES;
//        [[AnalyticsManager manager] openURL:url];
//    }
    
    
    // 跳转模块
    //可无，无则默认为qn
    if ([[url parameterForKey:@"service"] isEqualToString:@"qn"] ||[url parameterForKey:@"service"].length == 0) {
        self.isQNModule = YES;
    }
    else
    {
        self.isQNModule = NO;
    }
    
    // 跳转模块
    NSString* moduleString = [url parameterForKey:@"module"];
    [self getURL:url moduleType:moduleString];
    
    [self dealWithURL];
    
    return YES;
}


- (void)getURL:(NSURL *)url moduleType:(NSString *)moduleString {
    //    if( [moduleString isEqualToString:@"emf"] ) {
    //        // 跳转emf
    //        _type = URLTypeEmf;
    //    }else if ([moduleString isEqualToString:@"setting"]) {
    //        _type = URLTypeSetting;
    //    }else if ([moduleString isEqualToString:@"ladydetail"]) {
    //        _type = URLTypeLadyDetail;
    //        _urlParameter = [url parameterForKey:@"ladyid"];
    //
    //    }else if ([moduleString isEqualToString:@"chatlady"]) {
    //        _type = URLTypeChatLady;
    //        _urlParameter = [url parameterForKey:@"ladyid"];
    //    }

}

- (BOOL)dealWithURL {
    // 标记需要处理
    self.hasHandle = YES;
    
    LoginManager* manager = [LoginManager manager];
    switch (manager.status) {
        case NONE: {
            // 没登陆
        }
        case LOGINING:{
            // 登陆中
        }break;
        case LOGINED:{
            // 已经登陆
            [self callDelegate];
        }break;
        default:
            break;
    }
    
    return NO;
}

- (void)callDelegate {
    if( self.hasHandle ) {
        self.hasHandle = NO;
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        // 点击推送进入到前台会将此标记位改为NO,只会响应active
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LiveUrlHandlerDelegate> delegate = value.nonretainedObjectValue;
                    if( [delegate  respondsToSelector:@selector(liveUrlHandlerActive:openWithModule:)] ) {
//                        [delegate handlerActive:self openWithModule:self.type];
                        [delegate liveUrlHandlerActive:self openWithModule:self.type];
                    }
                }
            }
        }else {
            @synchronized(self.delegates) {
                for(NSValue* value in self.delegates) {
                    id<LiveUrlHandlerDelegate> delegate = value.nonretainedObjectValue;
                    if( [delegate  respondsToSelector:@selector(liveUrlHandler:openWithModule:)] ) {
//                        [delegate handler:self openWithModule:self.type];
                        [delegate liveUrlHandler:self openWithModule:self.type];
                    }
                }
            }
        }
        
        
        
        
    }
}

#pragma mark - LoginManager回调
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg serverId:(int)serverId {
    NSLog(@"URLHandler::onLogin( 接收登录回调 success : %d )", success);
    // 有未处理的URL请求
    if( success ) {
        [self callDelegate];
    }
}
@end
