//
//  InviteIdItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "InviteIdItemObject.h"
@interface InviteIdItemObject () <NSCoding>
@end


@implementation InviteIdItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.invitationId = [coder decodeObjectForKey:@"invitationId"];
        self.oppositeId = [coder decodeObjectForKey:@"oppositeId"];
        self.oppositeNickName = [coder decodeObjectForKey:@"oppositeNickName"];
        self.oppositePhotoUrl = [coder decodeObjectForKey:@"oppositePhotoUrl"];
        self.oppositeLevel = [coder decodeIntForKey:@"oppositeLevel"];
        self.oppositeAge = [coder decodeIntForKey:@"oppositeAge"];
        self.oppositeCountry = [coder decodeObjectForKey:@"oppositeCountry"];
        self.read = [coder decodeBoolForKey:@"read"];
        self.inviTime = [coder decodeIntegerForKey:@"inviTime"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.replyType = [coder decodeIntForKey:@"replyType"];
        self.validTime = [coder decodeIntForKey:@"validTime"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.invitationId forKey:@"invitationId"];
    [coder encodeObject:self.oppositeId forKey:@"oppositeId"];
    [coder encodeObject:self.oppositeNickName forKey:@"oppositeNickName"];
    [coder encodeObject:self.oppositePhotoUrl forKey:@"oppositePhotoUrl"];
    [coder encodeInt:self.oppositeLevel forKey:@"oppositeLevel"];
    [coder encodeInt:self.oppositeAge forKey:@"oppositeAge"];
    [coder encodeObject:self.oppositeCountry forKey:@"oppositeCountry"];
    [coder encodeBool:self.read forKey:@"read"];
    [coder encodeInteger:self.inviTime forKey:@"inviTime"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.replyType forKey:@"replyType"];
    [coder encodeInt:self.validTime forKey:@"validTime"];
}

@end
