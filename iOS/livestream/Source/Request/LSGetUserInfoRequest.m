//
//  LSGetUserInfoRequest.m
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGetUserInfoRequest.h"

@implementation LSGetUserInfoRequest
- (instancetype)init{
    if (self = [super init]) {
        self.userId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getUserInfo:self.userId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSUserInfoItemObject * _Nullable userInfoItem) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, userInfoItem);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {

        LSUserInfoItemObject * userInfoItem = [[LSUserInfoItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, userInfoItem);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
