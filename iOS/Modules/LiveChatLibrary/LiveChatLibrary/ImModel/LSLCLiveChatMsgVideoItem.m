//
//  LSLCLiveChatMsgVideoItem.m
//  dating
//
//  Created by Calvin on 19/3/15.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatMsgVideoItem.h"

@implementation LSLCLiveChatMsgVideoItem

- (LSLCLiveChatMsgVideoItem *)init
{
    self = [super init];
    if (nil != self)
    {
        self.videoId = @"";
        self.sendId = @"";
        self.videoDesc = @"";
        self.videoUrl = @"";
        self.charge = NO;
        //        self.thumbPhotoFilePath = @"";
        self.bigPhotoFilePath = @"";
        self.videoFilePath = @"";
    }
    return self;
}
@end
