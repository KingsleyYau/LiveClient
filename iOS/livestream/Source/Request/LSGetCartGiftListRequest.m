//
//  LSGetCartGiftListRequest.m
//  dating
//
//  Created by Alex on 19/09/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSGetCartGiftListRequest.h"

@implementation LSGetCartGiftListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.start = 0;
        self.step = 0;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getCartGiftList:self.start step:self.step finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int total, NSArray<LSMyCartItemObject *> *array) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, total, array);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray* arrayList = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, 0, arrayList);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
