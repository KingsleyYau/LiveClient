//
//  GetLiveRoomUserPhotoRequest.m
//  dating
//
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetLiveRoomUserPhotoRequest.h"

@implementation GetLiveRoomUserPhotoRequest
- (instancetype)init{
    if (self = [super init]) {

    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getLiveRoomUserPhoto:self.token userId:self.userId photoType:self.photoType finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [weakSelf.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, photoUrl);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"");
    }

    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
