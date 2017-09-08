 //
//  ConfigManager.m
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ConfigManager.h"

@interface ConfigManager () {
    
}

@property (nonatomic, strong) ConfigItemObject* item;
@property (nonatomic, strong) NSMutableArray* finishHandlers;
@property (nonatomic, assign) NSInteger requestId;
@end

static ConfigManager* gManager = nil;
@implementation ConfigManager
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.item = nil;
        self.finishHandlers = [NSMutableArray array];
        self.requestId = [RequestManager manager].invalidRequestId;
    }
    return self;
}

- (BOOL)synConfig:(GetConfigFinishHandler _Nullable)finishHandler {
    if( finishHandler ) {
        // 缓存回调
        [self.finishHandlers addObject:finishHandler];
    }
    
    if( self.requestId == [RequestManager manager].invalidRequestId ) {
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
            self.requestId = [[RequestManager manager] getConfig:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, ConfigItemObject * _Nonnull item) {
                // 接口返回
                __block NSInteger blockErrnum = errnum;
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
                    self.requestId = [RequestManager manager].invalidRequestId;
                });
            }];
            
            if( self.requestId != [RequestManager manager].invalidRequestId ) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)callbackConfigStatus:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    for(GetConfigFinishHandler handler in self.finishHandlers) {
        handler(success, errnum, errmsg, self.item);
    }
    
    // 清除所有回调
    [self.finishHandlers removeAllObjects];
}

- (void)clean {
    self.item = nil;
}

@end
