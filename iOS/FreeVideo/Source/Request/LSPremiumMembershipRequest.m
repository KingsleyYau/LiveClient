//
//  LSPremiumMembershipRequest.m
//  dating
//
//  Created by Max on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSPremiumMembershipRequest.h"

@implementation LSPremiumMembershipRequest
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
        NSInteger request = [self.manager premiumMembership:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg, LSOrderProductItemObject * _Nonnull productItem) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                HTTP_LCC_ERR_TYPE errCode = HTTP_LCC_ERR_FAIL;
                if (errnum.length <= 0) {
                    errCode = HTTP_LCC_ERR_SUCCESS;
                }
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errCode errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, productItem);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSOrderProductItemObject * item = [[LSOrderProductItemObject alloc] init];
        self.finishHandler(NO, @"", errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
