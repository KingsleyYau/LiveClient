//
//  ZBBookingUnreadUnhandleNumItemObject.m
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBBookingUnreadUnhandleNumItemObject.h"
@interface ZBBookingUnreadUnhandleNumItemObject () <NSCoding>
@end


@implementation ZBBookingUnreadUnhandleNumItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.totalNoReadNum = [coder decodeIntForKey:@"totalNoReadNum"];
        self.pendingNoReadNum = [coder decodeIntForKey:@"pendingNoReadNum"];
        self.scheduledNoReadNum = [coder decodeIntForKey:@"scheduledNoReadNum"];
        self.historyNoReadNum = [coder decodeIntForKey:@"historyNoReadNum"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.totalNoReadNum forKey:@"totalNoReadNum"];
    [coder encodeInt:self.pendingNoReadNum forKey:@"pendingNoReadNum"];
    [coder encodeInt:self.scheduledNoReadNum forKey:@"scheduledNoReadNum"];
    [coder encodeInt:self.historyNoReadNum forKey:@"historyNoReadNum"];
}

@end
