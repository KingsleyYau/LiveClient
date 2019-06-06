//
//  LSGetNoReadNumProgramRequest.m(已废弃)
//  dating
//
//  Created by Max on 18/04/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGetNoReadNumProgramRequest.h"

@implementation LSGetNoReadNumProgramRequest
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
        NSInteger request = [self.manager getNoReadNumProgram:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int num) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }

            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, num);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {

        self.finishHandler(NO, errnum, errmsg, 0);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
