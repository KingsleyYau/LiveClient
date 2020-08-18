//
//  LSSendScheduleInviteRequest.m
//  dating
//
//  Created by Alex on 20/03/31.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSendScheduleInviteRequest.h"

@implementation LSSendScheduleInviteRequest
- (instancetype)init{
    if (self = [super init]) {
        self.type = LSSCHEDULEINVITETYPE_EMF;
        self.refId = @"";
        self.anchorId = @"";
        self.timeZoneId = @"";
        self.startTime = @"";
        self.duration = 0;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager sendScheduleInvite:self.type refId:self.refId anchorId:self.anchorId timeZoneId:self.timeZoneId startTime:self.startTime duration:self.duration finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSendScheduleInviteItemObject *item, NSInteger activityTime) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item, activityTime);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
         LSSendScheduleInviteItemObject *item = [[LSSendScheduleInviteItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item, 0);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
