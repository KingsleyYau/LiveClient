//
//  LSUpdateProfileRequest.m
//  dating
//
//  Created by Alex on 18/6/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSUpdateProfileRequest.h"

@implementation LSUpdateProfileRequest
- (instancetype)init{
    if (self = [super init]) {
        self.weight = 0;
        self.height = 0;
        self.language = 0;
        self.ethnicity = 0;
        self.religion = 0;
        self.education = 0;
        self.profession = 0;
        self.income = 0;
        self.children = 0;
        self.smoke = 0;
        self.drink = 0;
        self.resume = @"";
        self.zodiac = 0;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager updateProfile:self.weight height:self.height language:self.language ethnicity:self.ethnicity religion:self.religion education:self.education profession:self.profession income:self.income children:self.children smoke:self.smoke drink:self.drink resume:self.resume interests:self.interests zodiac:self.zodiac finish:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BOOL isModify) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {

                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, isModify);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, NO);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
