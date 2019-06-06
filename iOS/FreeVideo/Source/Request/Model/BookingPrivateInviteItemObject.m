//
//  BookingPrivateInviteItemObject.m
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BookingPrivateInviteItemObject.h"
@interface BookingPrivateInviteItemObject () <NSCoding>
@end


@implementation BookingPrivateInviteItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.invitationId = [coder decodeObjectForKey:@"invitationId"];
        self.toId = [coder decodeObjectForKey:@"toId"];
        self.fromId = [coder decodeObjectForKey:@"fromId"];
        self.oppositePhotoUrl = [coder decodeObjectForKey:@"oppositePhotoUrl"];
        self.oppositeNickName = [coder decodeObjectForKey:@"oppositeNickName"];
        self.read = [coder decodeBoolForKey:@"read"];
        self.intimacy = [coder decodeIntForKey:@"intimacy"];
        self.replyType = [coder decodeIntForKey:@"replyType"];
        self.bookTime = [coder decodeIntegerForKey:@"bookTime"];
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftBigImgUrl = [coder decodeObjectForKey:@"giftBigImgUrl"];
        self.giftSmallImgUrl = [coder decodeObjectForKey:@"giftSmallImgUrl"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
        self.validTime = [coder decodeIntForKey:@"validTime"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.invitationId forKey:@"invitationId"];
    [coder encodeObject:self.toId forKey:@"toId"];
    [coder encodeObject:self.fromId forKey:@"fromId"];
    [coder encodeObject:self.oppositePhotoUrl forKey:@"oppositePhotoUrl"];
    [coder encodeObject:self.oppositeNickName forKey:@"oppositeNickName"];
    [coder encodeBool:self.read forKey:@"read"];
    [coder encodeInt:self.intimacy forKey:@"intimacy"];
    [coder encodeInt:self.replyType forKey:@"replyType"];
    [coder encodeInteger:self.bookTime forKey:@"bookTime"];
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeObject:self.giftBigImgUrl forKey:@"giftBigImgUrl"];
    [coder encodeObject:self.giftSmallImgUrl forKey:@"giftSmallImgUrl"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];
    [coder encodeInt:self.validTime forKey:@"validTime"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
}

@end
