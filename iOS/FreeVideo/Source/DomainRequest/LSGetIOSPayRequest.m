//
//  LSGetIOSPayRequest.m
//  dating
//
//  Created by Max on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGetIOSPayRequest.h"

@implementation LSGetIOSPayRequest
- (instancetype)init{
    if (self = [super init]) {
        self.manid = @"";
        self.sid = @"";
        self.number = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getIOSPay:self.manid sid:self.sid number:self.number finishHandler:^(BOOL success, NSString * _Nonnull errCode, NSString * _Nonnull orderNo, NSString * _Nonnull productId)  {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                HTTP_LCC_ERR_TYPE errnum = [[LSRequestManager manager] getStringToHttpErrorType:errCode];
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:@""];
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
