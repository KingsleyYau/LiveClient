//
//  RoomInfoItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "RoomInfoItemObject.h"
@interface RoomInfoItemObject () <NSCoding>
@end


@implementation RoomInfoItemObject

- (id)init {
    if( self = [super init] ) {

        self.roomList = nil;
        self.inviteList = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomList = [coder decodeObjectForKey:@"roomList"];
        self.inviteList = [coder decodeObjectForKey:@"inviteList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomList forKey:@"roomList"];
    [coder encodeObject:self.inviteList forKey:@"inviteList"];
}

@end
