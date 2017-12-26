//
//  LSBannerRequest.m
//  dating
//
//  Created by Alex on 17/10/19.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSBannerRequest.h"

@implementation LSBannerRequest
- (instancetype)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager banner:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull bannerImg, NSString * _Nonnull bannerLink, NSString * _Nonnull bannerName) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, bannerImg, bannerLink, bannerName);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {

        self.finishHandler(NO, errnum, errmsg, @"", @"", @"");
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
