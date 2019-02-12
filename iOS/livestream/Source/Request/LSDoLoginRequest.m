//
//  LSDoLoginRequest.m
//  dating
//
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDoLoginRequest.h"

@implementation LSDoLoginRequest
- (instancetype)init{
    if (self = [super init]) {
        self.tokenId = @"";
        self.memberId = @"";
        self.versionCode = @"";
        self.deviceid = [[LSRequestManager manager] getDeviceId];
        self.model = [[UIDevice currentDevice] model];
        self.manufacturer = @"Apple";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager loginWithTokenAuth:self.tokenId memberId:self.memberId deviceid:self.deviceid versionCode:self.versionCode model:self.model manufacturer:self.manufacturer finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {

                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSLoginItemObject * item = [[LSLoginItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
