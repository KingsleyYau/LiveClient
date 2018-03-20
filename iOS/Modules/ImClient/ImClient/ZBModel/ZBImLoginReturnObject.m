//
//  ImLoginReturnObject.m
//  dating
//
//  Created by Alex on 17/09/07.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ZBImLoginReturnObject.h"
@interface ZBImLoginReturnObject () <NSCoding>
@end


@implementation ZBImLoginReturnObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomList = [coder decodeObjectForKey:@"roomList"];
        self.inviteList = [coder decodeObjectForKey:@"inviteList"];
        self.scheduleRoomList = [coder decodeObjectForKey:@"scheduleRoomList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomList forKey:@"roomList"];
    [coder encodeObject:self.inviteList forKey:@"inviteList"];
    [coder encodeObject:self.scheduleRoomList forKey:@"scheduleRoomList"];

}

@end
