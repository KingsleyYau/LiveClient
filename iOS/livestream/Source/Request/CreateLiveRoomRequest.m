//
//  CreateLiveRoomRequest.m
//  dating
//
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CreateLiveRoomRequest.h"

@implementation CreateLiveRoomRequest
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
        NSInteger request = [self.manager createLiveRoom:self.token roomName:self.roomName roomPhotoId:self.roomPhotoId finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull roomurl) {
            BOOL bFlag = NO;

            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [weakSelf.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, roomId, roomurl);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"", @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
