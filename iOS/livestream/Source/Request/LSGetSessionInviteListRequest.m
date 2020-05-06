//
//  LSGetSessionInviteListRequest.m
//  dating
//
//  Created by Alex on 20/03/31.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSGetSessionInviteListRequest.h"

@implementation LSGetSessionInviteListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.type = LSSCHEDULEINVITETYPE_EMF;
        self.refId = @"";

    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getSessionInviteList:self.type refId:self.refId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray *array) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, array);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray* array = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
