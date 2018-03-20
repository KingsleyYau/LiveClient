//
//  LSEmailRegisterRequest.m
//  dating
//
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSEmailRegisterRequest.h"

@implementation LSEmailRegisterRequest
- (instancetype)init{
    if (self = [super init]) {
        self.email = @"";
        self.passWord = @"";
        self.gender = GENDERTYPE_MAN;
        self.nickName = @"";
        self.birthDay = @"";
        self.inviteCode = @"";
        self.model = [[LSRequestManager manager] getModelType];
        self.deviceId = [[LSRequestManager manager] getDeviceId];
        self.manufacturer = @"Apple";
        self.utmReferrer = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager mailRegister:self.email passWord:self.passWord gender:self.gender nickName:self.nickName birthDay:self.birthDay inviteCode:self.inviteCode model:self.model deviceid:self.deviceId manufacturer:self.manufacturer utmReferrer:self.utmReferrer finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
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
