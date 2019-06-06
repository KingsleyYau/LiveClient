//
//  LSGetShowRoomInfoRequest.m
//  dating
//
//  Created by Max on 18/04/23.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGetShowRoomInfoRequest.h"

@implementation LSGetShowRoomInfoRequest
- (instancetype)init{
    if (self = [super init]) {
        self.liveShowId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getShowRoomInfo:self.liveShowId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSProgramItemObject * _Nullable item, NSString * _Nonnull roomId, LSHttpAuthorityItemObject *_Nonnull privItem) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }

            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item, roomId, privItem);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSProgramItemObject * item = [[LSProgramItemObject alloc] init];
        LSHttpAuthorityItemObject * privItem = [[LSHttpAuthorityItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item, @"", privItem);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
