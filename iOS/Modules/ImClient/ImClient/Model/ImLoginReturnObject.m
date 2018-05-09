//
//  ImLoginReturnObject.m
//  dating
//
//  Created by Alex on 17/09/07.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ImLoginReturnObject.h"
@interface ImLoginReturnObject () <NSCoding>
@end


@implementation ImLoginReturnObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomList = [coder decodeObjectForKey:@"roomList"];
        self.inviteList = [coder decodeObjectForKey:@"inviteList"];
        self.scheduleRoomList = [coder decodeObjectForKey:@"scheduleRoomList"];
        self.ongoingShowList = [coder decodeObjectForKey:@"ongoingShowList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomList forKey:@"roomList"];
    [coder encodeObject:self.inviteList forKey:@"inviteList"];
    [coder encodeObject:self.scheduleRoomList forKey:@"scheduleRoomList"];
    [coder encodeObject:self.ongoingShowList forKey:@"ongoingShowList"];

}

@end
