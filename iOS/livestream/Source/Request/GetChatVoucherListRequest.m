//
//  GetChatVoucherListRequest.m
//  dating
//
//  Created by Alex on 19/6/11.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "GetChatVoucherListRequest.h"

@implementation GetChatVoucherListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.start = 0;
        self.step = 1000;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getChatVoucherList:self.start step:self.step finishHandler:^(BOOL success, NSString *errnum, NSString *errmsg, NSArray<VoucherItemObject *> *array, int totalCount) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                HTTP_LCC_ERR_TYPE errCode = [[LSRequestManager manager] getStringToHttpErrorType:errnum];
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errCode errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, array, totalCount);
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
        self.finishHandler(NO, @"", errmsg, array, 0);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
