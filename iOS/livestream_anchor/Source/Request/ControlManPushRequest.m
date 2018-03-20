//
//  ControlManPushRequest.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ControlManPushRequest.h"

@implementation ControlManPushRequest
- (instancetype)init{
    if (self = [super init]) {
        self.roomId = @"";
        self.control = CONTROLTYPE_UNKNOW;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager controlManPush:self.roomId control:self.control finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSMutableArray<NSString *> * _Nonnull manPushUrl)  {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, manPushUrl);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray* nsUploadUrls = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, nsUploadUrls);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
