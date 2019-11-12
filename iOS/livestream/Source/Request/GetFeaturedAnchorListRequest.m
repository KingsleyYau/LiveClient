//
//  GetFeaturedAnchorListRequest.m
//  dating
//
//  Created by Max on 19/11/12.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "GetFeaturedAnchorListRequest.h"

@implementation GetFeaturedAnchorListRequest
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
        NSInteger request = [self.manager getFeaturedAnchorList:self.start step:self.step finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, array);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSArray* items = [NSArray array];
        self.finishHandler(NO, errnum, errmsg, items);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
