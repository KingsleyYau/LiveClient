//
//  GetPhoneVerifyCodeRequest.m
//  dating
//
//  Created by Alex on 17/9/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetPhoneVerifyCodeRequest.h"

@implementation GetPhoneVerifyCodeRequest
- (instancetype)init{
    if (self = [super init]) {
        self.country = @"";
        self.areaCode = @"";
        self.phoneNo = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getPhoneVerifyCode:self.country areaCode:self.areaCode phoneNo:self.phoneNo finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
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

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {

        self.finishHandler(NO, errnum, errmsg);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end