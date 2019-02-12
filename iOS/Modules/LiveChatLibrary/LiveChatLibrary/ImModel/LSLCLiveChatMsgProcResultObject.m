//
//  LSLCLiveChatMsgProcResultObject.m
//  dating
//
//  Created by  Samson on 6/3/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatMsgProcResultObject.h"

@implementation LSLCLiveChatMsgProcResultObject
/**
 *  初始化
 *
 *  @return object
 */
- (LSLCLiveChatMsgProcResultObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.errType = LSLIVECHAT_LCC_ERR_SUCCESS;
        self.errNum = @"";
        self.errMsg = @"";
    }
    return self;
}
@end
