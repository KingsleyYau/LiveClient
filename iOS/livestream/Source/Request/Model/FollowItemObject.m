//
//  FollowItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "FollowItemObject.h"
@interface FollowItemObject () <NSCoding>
@end


@implementation FollowItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.roomName = [coder decodeObjectForKey:@"roomName"];
        self.roomPhotoUrl = [coder decodeObjectForKey:@"roomPhotoUrl"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.loveLevel = [coder decodeIntForKey:@"loveLevel"];
        self.addDate = [coder decodeIntegerForKey:@"addDate"];
        self.interest = [coder decodeObjectForKey:@"interest"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.roomName forKey:@"roomName"];
    [coder encodeObject:self.roomPhotoUrl forKey:@"roomPhotoUrl"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeInt:self.loveLevel forKey:@"loveLevel"];
    [coder encodeInteger:self.addDate forKey:@"addDate"];
    [coder encodeObject:self.interest forKey:@"interest"];
}

@end
