//
//  ImInviteReplyItemObject.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImInviteReplyItemObject.h"

@implementation ImInviteReplyItemObject

- (id)init {
    if( self = [super init] ) {
        self.inviteId = @"";
        self.replyType = REPLYTYPE_REJECT;
        self.roomId = @"";
        self.roomType = ROOMTYPE_NOLIVEROOM;
        self.anchorId = @"";
        self.nickName = @"";
        self.avatarImg = @"";
        self.msg = @"";
        self.status = IMCHATONLINESTATUS_OFF;;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.replyType = [coder decodeIntForKey:@"replyType"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.msg = [coder decodeObjectForKey:@"msg"];
        self.status = [coder decodeIntForKey:@"status"];
        self.priv = [coder decodeObjectForKey:@"priv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeInt:self.replyType forKey:@"replyType"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeObject:self.msg forKey:@"msg"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.priv forKey:@"priv"];
}


@end
