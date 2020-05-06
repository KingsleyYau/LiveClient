//
//  ImScheduleMsgObject.m
//  livestream
//
//  Created by Max on 2020/4/3.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import "ImScheduleMsgObject.h"

@implementation ImScheduleMsgObject

- (id)init {
    if( self = [super init] ) {
        self.scheduleInviteId = @"";
        self.status = IMSCHEDULESENDSTATUS_PENDING;
        self.sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
        self.duration = 0;
        self.origintduration = 0;
        self.period = @"";
        self.startTime = 0;
        self.statusUpdateTime = 0;
        self.sendTime = 0;
        self.nickName = @"";
        self.fromId = @"";
        self.toNickName = @"";
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.scheduleInviteId = [coder decodeObjectForKey:@"scheduleInviteId"];
        self.status = [coder decodeIntForKey:@"status"];
        self.sendFlag = [coder decodeIntForKey:@"sendFlag"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.origintduration = [coder decodeIntForKey:@"origintduration"];
        self.period = [coder decodeObjectForKey:@"period"];
        self.startTime = [coder decodeIntegerForKey:@"startTime"];
        self.statusUpdateTime = [coder decodeIntegerForKey:@"statusUpdateTime"];
        self.sendTime = [coder decodeIntegerForKey:@"sendTime"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.fromId = [coder decodeObjectForKey:@"fromId"];
        self.toNickName = [coder decodeObjectForKey:@"toNickName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.scheduleInviteId forKey:@"scheduleInviteId"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeInt:self.sendFlag forKey:@"sendFlag"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeInt:self.origintduration forKey:@"origintduration"];
    [coder encodeObject:self.period forKey:@"period"];
    [coder encodeInteger:self.startTime forKey:@"startTime"];
    [coder encodeInteger:self.statusUpdateTime forKey:@"statusUpdateTime"];
    [coder encodeInteger:self.sendTime forKey:@"sendTime"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.fromId forKey:@"fromId"];
    [coder encodeObject:self.toNickName forKey:@"toNickName"];

}


@end
