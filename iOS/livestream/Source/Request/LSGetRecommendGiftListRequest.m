//
//  LSGetRecommendGiftListRequest.m
//  dating
//
//  Created by Alex on 19/09/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSGetRecommendGiftListRequest.h"

@implementation LSGetRecommendGiftListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.giftId = @"";
        self.anchorId = @"";
        self.number = 0;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        NSInteger request = [self.manager getRecommendGiftList:self.giftId anchorId:self.anchorId number:self.number finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSFlowerGiftItemObject *> *array)  {
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
        NSMutableArray* arrayList = [NSMutableArray array];
        self.finishHandler(NO, errnum, errmsg, arrayList);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
