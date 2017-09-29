//
//  ImBookingReplyObject.m
//  dating
//
//  Created by Alex on 17/09/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ImBookingReplyObject.h"
@interface ImBookingReplyObject () <NSCoding>
@end


@implementation ImBookingReplyObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.replyType = [coder decodeIntForKey:@"replyType"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.msg = [coder decodeObjectForKey:@"msg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeInt:self.replyType forKey:@"replyType"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeObject:self.msg forKey:@"msg"];

}

@end
