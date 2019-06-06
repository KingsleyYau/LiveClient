//
//  LSHangoutListItemObject.m
//  dating
//
//  Created by Alex on 18/1/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHangoutListItemObject.h"
@interface LSHangoutListItemObject () <NSCoding>
@end


@implementation LSHangoutListItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.nickName = @"";
        self.avatarImg = @"";
        self.coverImg = @"";
        self.onlineStatus = ONLINE_STATUS_UNKNOWN;
        self.friendsNum = 0;
        self.invitationMsg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.coverImg = [coder decodeObjectForKey:@"coverImg"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.friendsNum = [coder decodeIntForKey:@"friendsNum"];
        self.invitationMsg = [coder decodeObjectForKey:@"invitationMsg"];
        self.friendsInfoList = [coder decodeObjectForKey:@"friendsInfoList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeObject:self.coverImg forKey:@"coverImg"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeInt:self.friendsNum forKey:@"friendsNum"];
    [coder encodeObject:self.invitationMsg forKey:@"invitationMsg"];
    [coder encodeObject:self.friendsInfoList forKey:@"friendsInfoList"];
}

@end
