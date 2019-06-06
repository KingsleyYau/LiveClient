//
//  LSGetValidateCodeRequest.m
//  dating
//
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGetValidateCodeRequest.h"

@implementation LSGetValidateCodeRequest
- (instancetype)init{
    if (self = [super init]) {
        self.validateCodeType = LSVALIDATECODETYPE_LOGIN;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getValidateCode:self.validateCodeType finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE  errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len) {
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
