//
//  LSLCRecentVideoItemObject.m
//  dating
//
//  Created by Calvin on 19/3/15.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLCRecentVideoItemObject.h"

@implementation LSLCRecentVideoItemObject

- (LSLCRecentVideoItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.videoId = @"";
        self.title = @"";
        self.inviteid = @"";
        self.videoUrl = @"";
        self.videoCover = @"";
    }
    return self;
}
@end
