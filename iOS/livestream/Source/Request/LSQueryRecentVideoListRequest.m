//
//  LSQueryRecentVideoListRequest.m
//  dating
//
//  Created by Alex on 19/1/22.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSQueryRecentVideoListRequest.h"
#import <livechatmanmanager/ILSLiveChatErrCode.h>

@implementation LSQueryRecentVideoListRequest
- (instancetype)init{
    if (self = [super init]) {
        self.userSid = @"";
        self.userId = @"";
        self.womanId = @"";
    }
    
    return self;
}

- (void)dealloc {
    
}

- (BOOL)sendRequest {

        __weak typeof(self) weakSelf = self;
    NSInteger request = [[LSLiveChatRequestManager manager] queryRecentVideoList:self.userSid userId:self.userId womanId:self.womanId finish:^(BOOL success, NSString *errnum, NSString *errmsg, NSArray<LSLCRecentVideoItemObject *> *itemArray)  {
            BOOL bFlag = NO;
        HTTP_LCC_ERR_TYPE errNo = HTTP_LCC_ERR_FAIL;
        
        if ([errnum isEqualToString:[NSString stringWithUTF8String:LIVECHATERRCODE_TOKEN_OVER]]) {
            errNo = HTTP_LCC_ERR_TOKEN_EXPIRE;
        } else if (errnum == nil || errnum.length == 0) {
            errNo = HTTP_LCC_ERR_SUCCESS;
        }
            // 没有处理过, 才进入LSSessionRequestManager处理
            if( !weakSelf.isHandleAlready && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:weakSelf handleRespond:success errnum:errNo errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag && weakSelf.finishHandler ) {
                weakSelf.finishHandler(success, errnum, errmsg, itemArray);
                [weakSelf finishRequest];
            }
        }];
        return request != 0;

}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSMutableArray* array = [NSMutableArray array];
        self.finishHandler(NO, @"", errmsg, array);
    }
    
    [super callRespond:success errnum:errnum errmsg:errmsg];
}

@end
