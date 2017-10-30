//
//  GetTalentListRequest.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetTalentListRequest.h"

@implementation GetTalentListRequest
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
        NSInteger request = [self.manager getTalentList:self.roomId finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GetTalentItemObject *> * _Nonnull array) {
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

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray *array = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
