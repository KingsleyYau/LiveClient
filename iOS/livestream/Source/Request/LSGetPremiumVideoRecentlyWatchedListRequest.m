//
//  LSGetPremiumVideoRecentlyWatchedListRequest.m
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSGetPremiumVideoRecentlyWatchedListRequest.h"

@implementation LSGetPremiumVideoRecentlyWatchedListRequest
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
        NSInteger request = [self.manager getPremiumVideoRecentlyWatchedList:self.start step:self.step finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoRecentlyWatchedItemObject *> *array) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, totalCount, array);
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
        self.finishHandler(NO, errnum, errmsg, 0, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
