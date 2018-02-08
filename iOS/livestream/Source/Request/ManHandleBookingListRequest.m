//
//  ManHandleBookingListRequest.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ManHandleBookingListRequest.h"

@implementation ManHandleBookingListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.type = BOOKINGLISTTYPE_HISTORY;
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
        NSInteger request = [self.manager manHandleBookingList:self.type start:self.start step:self.step finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BookingPrivateInviteListObject * _Nonnull item) {
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
        BookingPrivateInviteListObject* item = [[BookingPrivateInviteListObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
