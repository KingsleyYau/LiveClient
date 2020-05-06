//
//  LSScheduleInviteDetailItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSScheduleInviteDetailItemObject.h"
@interface LSScheduleInviteDetailItemObject () <NSCoding>
@end


@implementation LSScheduleInviteDetailItemObject
- (id)init {
    if( self = [super init] ) {
        self.inviteId = @"";
        self.anchorId = @"";
        self.sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
        self.isSummerTime = NO;
        self.startTime = 0;
        self.endTime = 0;
        self.addTime = 0;
        self.statusUpdateTime = 0;
        self.timeZoneValue = @"";
        self.timeZoneCity = @"";
        self.duration = 0;
        self.status = LSSCHEDULEINVITESTATUS_PENDING;
        self.cancelerName = @"";
        self.type = LSSCHEDULEINVITETYPE_LIVECHAT;
        self.refId = @"";
        self.isActive = NO;

    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.sendFlag = [coder decodeIntForKey:@"sendFlag"];
        self.isSummerTime = [coder decodeBoolForKey:@"isSummerTime"];
        self.startTime = [coder decodeIntegerForKey:@"startTime"];
        self.endTime = [coder decodeIntegerForKey:@"endTime"];
        self.addTime = [coder decodeIntegerForKey:@"addTime"];
        self.statusUpdateTime = [coder decodeIntegerForKey:@"statusUpdateTime"];
        self.timeZoneValue = [coder decodeObjectForKey:@"timeZoneValue"];
        self.timeZoneCity = [coder decodeObjectForKey:@"timeZoneCity"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.status = [coder decodeIntForKey:@"status"];
        self.cancelerName = [coder decodeObjectForKey:@"cancelerName"];
        self.type = [coder decodeIntForKey:@"type"];
        self.refId = [coder decodeObjectForKey:@"refId"];
        self.isActive = [coder decodeBoolForKey:@"isActive"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeInt:self.sendFlag forKey:@"sendFlag"];
    [coder encodeBool:self.isSummerTime forKey:@"isSummerTime"];
    [coder encodeInteger:self.startTime forKey:@"startTime"];
    [coder encodeInteger:self.endTime forKey:@"endTime"];
    [coder encodeInteger:self.addTime forKey:@"addTime"];
    [coder encodeInteger:self.statusUpdateTime forKey:@"statusUpdateTime"];
    [coder encodeObject:self.timeZoneValue forKey:@"timeZoneValue"];
    [coder encodeObject:self.timeZoneCity forKey:@"timeZoneCity"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.cancelerName forKey:@"cancelerName"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.refId forKey:@"refId"];
    [coder encodeBool:self.isActive forKey:@"isActive"];
}

@end
