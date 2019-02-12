//
//  LMPrivateMsgContactObject.m
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LMPrivateMsgContactObject.h"
@interface LMPrivateMsgContactObject () <NSCoding>
@end


@implementation LMPrivateMsgContactObject

- (id)init {
    if( self = [super init] ) {
        self.userId = @"";
        self.nickName = @"";
        self.avatarImg = @"";
        self.onlineStatus = ONLINE_STATUS_UNKNOWN;
        self.lastMsg = @"";
        self.updateTime = 0;
        self.unreadNum = 0;
        self.isAnchor = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.lastMsg = [coder decodeObjectForKey:@"lastMsg"];
        self.updateTime = [coder decodeIntegerForKey:@"updateTime"];
        self.unreadNum = [coder decodeIntForKey:@"unreadNum"];
        self.isAnchor = [coder decodeBoolForKey:@"isAnchor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeObject:self.lastMsg forKey:@"lastMsg"];
    [coder encodeInteger:self.updateTime forKey:@"updateTime"];
    [coder encodeInt:self.unreadNum forKey:@"unreadNum"];
    [coder encodeBool:self.isAnchor forKey:@"isAnchor"];
}

@end
