//
//  IMAnchorRecvDealInviteItemObject.m
//  livestream
//
//  Created by Max on 2018/4/10
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorRecvDealInviteItemObject.h"

@implementation IMAnchorRecvDealInviteItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.type = [coder decodeIntForKey:@"type"];
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

}


@end
