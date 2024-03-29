//
//  LSGetIOSPayRequest.m
//  dating
//
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGetIOSPayRequest.h"

@implementation LSGetIOSPayRequest
- (instancetype)init{
    if (self = [super init]) {
        self.manid = @"";
        self.sid = @"";
        self.number = @"";
        self.siteid = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getIOSPay:self.manid sid:self.sid number:self.number siteid:self.siteid finishHandler:^(BOOL success, NSString * _Nonnull errCode, NSString * _Nonnull orderNo, NSString * _Nonnull productId) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:0 errmsg:errCode];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errCode, orderNo, productId);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errmsg, @"", @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
