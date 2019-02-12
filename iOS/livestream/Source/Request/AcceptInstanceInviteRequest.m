//
//  AcceptInstanceInviteRequest.m
//  dating
//
//  Created by Alex on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "AcceptInstanceInviteRequest.h"

@implementation AcceptInstanceInviteRequest
- (instancetype)init{
    if (self = [super init]) {
        self.inviteId = @"";
        self.isConfirm = false;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager acceptInstanceInvite:self.inviteId isConfirm:self.isConfirm finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, AcceptInstanceInviteItemObject * _Nonnull item, LSHttpAuthorityItemObject * _Nonnull priv) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item, priv);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        AcceptInstanceInviteItemObject* item = [[AcceptInstanceInviteItemObject alloc] init];
        LSHttpAuthorityItemObject* priv = [[LSHttpAuthorityItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item, priv);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
