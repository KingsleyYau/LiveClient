//
//  LSGetPremiumVideoDetailRequest.m
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSGetPremiumVideoDetailRequest.h"

@implementation LSGetPremiumVideoDetailRequest
- (instancetype)init{
    if (self = [super init]) {
        self.videoId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getPremiumVideoDetail:self.videoId finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSPremiumVideoDetailItemObject *item) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
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
        LSPremiumVideoDetailItemObject *item = [[LSPremiumVideoDetailItemObject alloc] init];
        self.finishHandler(NO, errnum, errmsg, item);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
