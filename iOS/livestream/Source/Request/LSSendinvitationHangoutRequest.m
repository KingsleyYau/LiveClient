//
//  LSSendinvitationHangoutRequest.m
//  dating
//
//  Created by Max on 18/04/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSendinvitationHangoutRequest.h"

@implementation LSSendinvitationHangoutRequest
- (instancetype)init{
    if (self = [super init]) {
        self.roomId = @"";
        self.anchorId = @"";
        self.recommendId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager sendInvitationHangout:self.roomId anchorId:self.anchorId recommendId:self.recommendId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull inviteId, int expire) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }

            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, roomId, inviteId, expire);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {

        self.finishHandler(NO, errnum, errmsg, @"", @"", 0);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
