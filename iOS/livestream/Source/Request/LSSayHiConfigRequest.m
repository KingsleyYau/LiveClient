//
//  LSSayHiConfigRequest.m
//  dating
//
//  Created by Alex on 19/4/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiConfigRequest.h"

@implementation LSSayHiConfigRequest
- (instancetype)init{
    if (self = [super init]) {

    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
    NSInteger request = [self.manager sayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
            BOOL bFlag = NO;
        
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate        respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
        
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;

}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSSayHiResourceConfigItemObject *item = [[LSSayHiResourceConfigItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
