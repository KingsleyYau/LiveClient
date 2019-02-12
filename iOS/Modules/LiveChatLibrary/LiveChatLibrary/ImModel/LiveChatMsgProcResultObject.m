//
//  LiveChatMsgProcResultObject.m
//  dating
//
//  Created by  Samson on 6/3/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "LiveChatMsgProcResultObject.h"

@implementation LiveChatMsgProcResultObject
/**
 *  初始化
 *
 *  @return object
 */
- (LiveChatMsgProcResultObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.errType = LCC_ERR_SUCCESS;
        self.errNum = @"";
        self.errMsg = @"";
    }
    return self;
}
@end
