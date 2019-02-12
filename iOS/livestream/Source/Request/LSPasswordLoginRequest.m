//
//  LSPasswordLoginRequest.m
//  dating
//
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSPasswordLoginRequest.h"

@implementation LSPasswordLoginRequest
- (instancetype)init{
    if (self = [super init]) {
        self.email = @"";
        self.password = @"";
        self.authCode = @"";

    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager loginWithPassword:self.email password:self.password authCode:self.authCode finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull memberId, NSString * _Nonnull sid) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {

                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, memberId, sid);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"", @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
