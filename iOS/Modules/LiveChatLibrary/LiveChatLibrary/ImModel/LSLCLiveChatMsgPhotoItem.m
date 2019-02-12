//
//  LSLCLiveChatMsgPhotoItem.m
//  dating
//
//  Created by lance on 16/7/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatMsgPhotoItem.h"

@implementation LSLCLiveChatMsgPhotoItem


- (LSLCLiveChatMsgPhotoItem *)init
{
    self = [super init];
    if (nil != self)
    {
        self.photoId = @"";
        self.photoDesc = @"";
        self.sendId = @"";
        self.showFuzzyFilePath = @"";
        self.thumbFuzzyFilePath = @"";
        self.srcFilePath = @"";
        self.showFuzzyFilePath = @"";
        self.thumbSrcFilePath = @"";
        self.charge = NO;
        
        
    }
    return self;
}

@end
