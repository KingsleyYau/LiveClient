 //
//  LSConfigManager.m
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSConfigManager.h"

@interface LSConfigManager () {
    
}

@property (nonatomic, strong) NSMutableArray* finishHandlers;
@property (nonatomic, assign) NSInteger requestId;
@end

static LSConfigManager* lSConfigManager = nil;
@implementation LSConfigManager
+ (instancetype)manager {
    if( lSConfigManager == nil ) {
        lSConfigManager = [[[self class] alloc] init];
    }
    return lSConfigManager;
}

- (id)init {
    if( self = [super init] ) {
        self.item = nil;
        self.finishHandlers = [NSMutableArray array];
        self.requestId = [LSRequestManager manager].invalidRequestId;
        [self loadConfigParam];
    }
    return self;
}

- (BOOL)synConfig:(GetConfigFinishHandler _Nullable)finishHandler {
    if( finishHandler ) {
        // 缓存回调
        [self.finishHandlers addObject:finishHandler];
    }
    
    if( self.requestId == [LSRequestManager manager].invalidRequestId ) {
        // 开始获取同步配置
        if( self.item ) {
            // 已经获取成功
            if( self.finishHandlers ) {
                for(GetConfigFinishHandler handler in self.finishHandlers) {
                    handler(YES, 0, @"", self.item);
                }
                
                // 清除所有回调
                [self.finishHandlers removeAllObjects];
            }
            
            return YES;
            
        } else {
            self.requestId = [[LSRequestManager manager] getConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ConfigItemObject * _Nonnull item) {
                // 接口返回
                __block HTTP_LCC_ERR_TYPE blockErrnum = errnum;
                __block NSString* blockErrmsg = errmsg;
                __block BOOL blockSuccess = success;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if( self.finishHandlers ) {
                        if( blockSuccess ) {
                            self.item = item;
                        }
                        
                        [self callbackConfigStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                    }
                    
                    // 请求完成
                    self.requestId = [LSRequestManager manager].invalidRequestId;
                });
            }];
            
            if( self.requestId != [LSRequestManager manager].invalidRequestId ) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)callbackConfigStatus:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    for(GetConfigFinishHandler handler in self.finishHandlers) {
        handler(success, errnum, errmsg, self.item);
    }
    
    // 清除所有回调
    [self.finishHandlers removeAllObjects];
}

- (void)clean {
    self.item = nil;
}

- (void)saveConfigParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.dontShow2WayVideoDialog forKey:@"dontShow2WayVideoDialog"];
    [userDefaults synchronize];
}

- (void)loadConfigParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.dontShow2WayVideoDialog = [userDefaults boolForKey:@"dontShow2WayVideoDialog"];
}

@end
