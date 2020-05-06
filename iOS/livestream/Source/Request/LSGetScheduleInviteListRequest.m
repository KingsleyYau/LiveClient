//
//  LSGetScheduleInviteListRequest.m
//  dating
//
//  Created by Alex on 20/03/31.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSGetScheduleInviteListRequest.h"

@implementation LSGetScheduleInviteListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.status = LSSCHEDULEINVITESTATUS_PENDING;
        self.sendFlag = LSSCHEDULESENDFLAGTYPE_ALL;
        self.anchorId = @"";
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
        NSInteger request = [self.manager getScheduleInviteList:self.status sendFlag:self.sendFlag anchorId:self.anchorId start:self.start step:self.step finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSScheduleInviteListItemObject *> *array)  {
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
        NSMutableArray* array = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
