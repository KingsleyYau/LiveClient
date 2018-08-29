//
//  LSGetHangoutGiftListRequest.m
//  dating
//
//  Created by Max on 18/05/08.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGetHangoutGiftListRequest.h"

@implementation LSGetHangoutGiftListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.roomId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getHangoutGiftList:self.roomId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSHangoutGiftListObject * _Nonnull item) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }

            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSHangoutGiftListObject* item = [[LSHangoutGiftListObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
