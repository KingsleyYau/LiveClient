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
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomName = [coder decodeObjectForKey:@"roomName"];
        self.roomPhotoUrl = [coder decodeObjectForKey:@"roomPhotoUrl"];
        self.status = [coder decodeIntForKey:@"status"];
        self.fansNum = [coder decodeIntForKey:@"fansNum"];
        self.country = [coder decodeObjectForKey:@"country"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.roomName forKey:@"roomName"];
    [coder encodeObject:self.roomPhotoUrl forKey:@"roomPhotoUrl"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeInt:self.fansNum forKey:@"fansNum"];
    [coder encodeObject:self.country forKey:@"country"];
}

@end
