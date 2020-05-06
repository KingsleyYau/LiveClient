//
//  LSSendScheduleInviteItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSendScheduleInviteItemObject.h"
@interface LSSendScheduleInviteItemObject () <NSCoding>
@end


@implementation LSSendScheduleInviteItemObject
- (id)init {
    if( self = [super init] ) {
        self.inviteId = @"";
        self.isSummerTime = NO;
        self.startTime = 0;
        self.addTime = 0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.isSummerTime = [coder decodeBoolForKey:@"isSummerTime"];
        self.startTime = [coder decodeIntegerForKey:@"startTime"];
        self.addTime = [coder decodeIntegerForKey:@"addTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeBool:self.isSummerTime forKey:@"isSummerTime"];
    [coder encodeInteger:self.startTime forKey:@"startTime"];
    [coder encodeInteger:self.addTime forKey:@"addTime"];
}

@end
