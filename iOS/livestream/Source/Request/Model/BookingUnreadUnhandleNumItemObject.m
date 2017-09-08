//
//  BookingUnreadUnhandleNumItemObject.m
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BookingUnreadUnhandleNumItemObject.h"
@interface BookingUnreadUnhandleNumItemObject () <NSCoding>
@end


@implementation BookingUnreadUnhandleNumItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.total = [coder decodeIntForKey:@"total"];
        self.handleNum = [coder decodeIntForKey:@"handleNum"];
        self.scheduledUnreadNum = [coder decodeIntForKey:@"scheduledUnreadNum"];
        self.historyUnreadNum = [coder decodeIntForKey:@"historyUnreadNum"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.total forKey:@"total"];
    [coder encodeInt:self.handleNum forKey:@"handleNum"];
    [coder encodeInt:self.scheduledUnreadNum forKey:@"scheduledUnreadNum"];
    [coder encodeInt:self.historyUnreadNum forKey:@"historyUnreadNum"];
}

@end
