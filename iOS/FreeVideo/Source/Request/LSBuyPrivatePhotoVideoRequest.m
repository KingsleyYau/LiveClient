//
//  LSBuyPrivatePhotoVideoRequest.m
//  dating
//
//  Created by Alex on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSBuyPrivatePhotoVideoRequest.h"

@implementation LSBuyPrivatePhotoVideoRequest
- (instancetype)init{
    if (self = [super init]) {
        self.emfId = @"";
        self.resourceId = @"";
        self.comsumeType = LSLETTERCOMSUMETYPE_CREDIT;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager buyPrivatePhotoVideo:self.emfId resourceId:self.resourceId comsumeType:self.comsumeType finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSBuyAttachItemObject *item) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, item);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        LSBuyAttachItemObject *item = [[LSBuyAttachItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
