//
//  GetLiveRoomModifyInfoRequest.m
//  dating
//
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetLiveRoomModifyInfoRequest.h"

@implementation GetLiveRoomModifyInfoRequest
- (instancetype)init{
    if (self = [super init]) {

    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getLiveRoomModifyInfo:self.token finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LiveRoomPersonalInfoItemObject* _Nonnull item) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [weakSelf.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
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

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LiveRoomPersonalInfoItemObject* item = [[LiveRoomPersonalInfoItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
