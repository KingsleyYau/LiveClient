//
//  LiveRoomInfoItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LiveRoomInfoItemObject.h"
@interface LiveRoomInfoItemObject () <NSCoding>
@end


@implementation LiveRoomInfoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.roomPhotoUrl = [coder decodeObjectForKey:@"roomPhotoUrl"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.interest = [coder decodeObjectForKey:@"interest"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.roomPhotoUrl forKey:@"roomPhotoUrl"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeObject:self.interest forKey:@"interest"];
}

@end
