//
//  LSCreateGiftOrderRequest.m
//  dating
//
//  Created by Alex on 19/09/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSCreateGiftOrderRequest.h"

@implementation LSCreateGiftOrderRequest
- (instancetype)init{
    if (self = [super init]) {
        self.anchorId = @"";
        self.greetingMessage = @"";
        self.specialDeliveryRequest = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager createGiftOrder:self.anchorId greetingMessage:self.greetingMessage specialDeliveryRequest:self.specialDeliveryRequest finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *orderNumber) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, orderNumber);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
