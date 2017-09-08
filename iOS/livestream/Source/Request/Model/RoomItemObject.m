//
//  RoomItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "RoomItemObject.h"
@interface RoomItemObject () <NSCoding>
@end


@implementation RoomItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomUrl = [coder decodeObjectForKey:@"roomUrl"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.roomUrl forKey:@"roomUrl"];

}

@end
