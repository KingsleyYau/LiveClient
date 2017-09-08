//
//  RideInfoObject.m
//  dating
//
//  Created by Alex on 17/8/15.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "RideInfoObject.h"
@interface RideInfoObject () <NSCoding>
@end


@implementation RideInfoObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.rideId = [coder decodeObjectForKey:@"rideId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rideId forKey:@"rideId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.name forKey:@"name"];
}

@end
