//
//  IMHangoutInviteItemObject.m
//  dating
//
//  Created by Alex on 19/1/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "IMHangoutInviteItemObject.h"
@interface IMHangoutInviteItemObject () <NSCoding>
@end


@implementation IMHangoutInviteItemObject

- (id)init {
    if( self = [super init] ) {
        self.logId = 0;
        self.isAnto = NO;
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.anchorCover = @"";
        self.InviteMessage = @"";
        self.weights = 0;
        self.avatarImg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.logId = [coder decodeIntForKey:@"logId"];
        self.isAnto = [coder decodeBoolForKey:@"isAnto"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.anchorCover = [coder decodeObjectForKey:@"anchorCover"];
        self.InviteMessage = [coder decodeObjectForKey:@"InviteMessage"];
        self.weights = [coder decodeIntForKey:@"weights"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeInt:self.logId forKey:@"logId"];
    [coder encodeBool:self.isAnto forKey:@"isAnto"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeObject:self.anchorCover forKey:@"anchorCover"];
    [coder encodeObject:self.InviteMessage forKey:@"InviteMessage"];
    [coder encodeInt:self.weights forKey:@"weights"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];

}

@end
