//
//  IMRecvDealInviteItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMRecvDealInviteItemObject.h"

@implementation IMRecvDealInviteItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.type = [coder decodeIntForKey:@"type"];
        self.expires = [coder decodeIntForKey:@"expires"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeInt:self.expires forKey:@"expires"];

}


@end
