//
//  LSRetrieveBannerRequest.m
//  dating
//
//  Created by Alex on 19/08/08.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSRetrieveBannerRequest.h"
#import "LSLoginManager.h"
@implementation LSRetrieveBannerRequest
- (instancetype)init{
    if (self = [super init]) {
        self.manId = [LSLoginManager manager].loginItem.userId;
        self.isAnchorPage = NO;
        self.bannerType = LSBANNERTYPE_UNKNOW;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager retrieveBanner:self.manId isAnchorPage:self.isAnchorPage bannerType:self.bannerType finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *htmUrl) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, htmUrl);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg, @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
