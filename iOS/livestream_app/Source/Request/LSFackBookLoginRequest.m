//
//  GetGiftListByUserIdRequest.m
//  dating
//
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSFackBookLoginRequest.h"

@implementation LSFackBookLoginRequest
- (instancetype)init{
    if (self = [super init]) {
        self.fToken = @"";
        self.nickName = @"";
        self.utmReferrer = @"";
        self.model = [[LSRequestManager manager] getModelType];
        self.deviceId = [[LSRequestManager manager] getDeviceId];
        self.manufacturer = @"Apple";
        self.inviteCode = @"";
        self.email = @"";
        self.passWord = @"";
        self.birthDay = @"";
        self.gender = GENDERTYPE_UNKNOW;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager fackBookLogin:self.fToken nickName:self.nickName utmReferrer:self.utmReferrer model:self.model deviceId:self.deviceId manufacturer:self.manufacturer inviteCode:self.inviteCode email:self.email passWord:self.passWord birthDay:self.birthDay gender:self.gender finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId)  {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, sessionId);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSString* sessionId = @"";
        self.finishHandler(NO, errnum, errmsg, sessionId);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
