//
//  IMProgramItemObject.m
//  dating
//
//  Created by Alex on 18/4/23.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "IMProgramItemObject.h"
@interface IMProgramItemObject () <NSCoding>
@end


@implementation IMProgramItemObject

- (id)init {
    if( self = [super init] ) {
        self.showLiveId = @"";
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.anchorAvatar = @"";
        self.showTitle = @"";
        self.showIntroduce = @"";
        self.cover = @"";
        self.approveTime = 0;
        self.startTime = 0;
        self.duration = 0;
        self.leftSecToStart = 0;
        self.leftSecToEnter = 0;
        self.price = 0.0;
        self.status = IMPROGRAMSTATUS_UNKNOW;
        self.ticketStatus = IMPROGRAMTICKETSTATUS_UNKNOW;
        self.isHasFollow = NO;
        self.isTicketFull = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.showLiveId = [coder decodeObjectForKey:@"showLiveId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.showTitle = [coder decodeObjectForKey:@"showTitle"];
        self.showIntroduce = [coder decodeObjectForKey:@"showIntroduce"];
        self.cover = [coder decodeObjectForKey:@"cover"];
        self.approveTime = [coder decodeIntegerForKey:@"approveTime"];
        self.startTime = [coder decodeIntegerForKey:@"startTime"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.leftSecToStart = [coder decodeIntForKey:@"leftSecToStart"];
        self.leftSecToEnter = [coder decodeIntForKey:@"leftSecToEnter"];
        self.price = [coder decodeDoubleForKey:@"price"];
        self.status = [coder decodeIntForKey:@"status"];
        self.ticketStatus = [coder decodeIntForKey:@"ticketStatus"];
        self.isHasFollow = [coder decodeBoolForKey:@"isHasFollow"];
        self.isTicketFull = [coder decodeBoolForKey:@"isTicketFull"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.showLiveId forKey:@"showLiveId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeObject:self.showTitle forKey:@"showTitle"];
    [coder encodeObject:self.showIntroduce forKey:@"showIntroduce"];
    [coder encodeObject:self.cover forKey:@"cover"];
    [coder encodeInteger:self.approveTime forKey:@"approveTime"];
    [coder encodeInteger:self.startTime forKey:@"startTime"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeInt:self.leftSecToStart forKey:@"leftSecToStart"];
    [coder encodeInt:self.leftSecToEnter forKey:@"leftSecToEnter"];
    [coder encodeDouble:self.price forKey:@"price"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeInt:self.ticketStatus forKey:@"ticketStatus"];
    [coder encodeBool:self.isHasFollow forKey:@"isHasFollow"];
    [coder encodeBool:self.isTicketFull forKey:@"isTicketFull"];
}

@end
