//
//  LiveChatMsgPhotoItem.m
//  dating
//
//  Created by lance on 16/7/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatMsgPhotoItem.h"

@implementation LiveChatMsgPhotoItem


- (LiveChatMsgPhotoItem *)init
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
