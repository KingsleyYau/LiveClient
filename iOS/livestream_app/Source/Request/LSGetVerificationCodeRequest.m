//
//  LSGetVerificationCodeRequest.m
//  dating
//
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGetVerificationCodeRequest.h"

@implementation LSGetVerificationCodeRequest
- (instancetype)init{
    if (self = [super init]) {
        self.verifyType = VERIFYCODETYPE_LOGIN;
        self.useCode = false;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getVerificationCode:self.verifyType useCode:self.useCode finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, data, len);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        const char * _Nullable data = "";
        
        self.finishHandler(NO, errnum, errmsg, data, 0);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
