//
//  RideItemObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "RideItemObject.h"
@interface RideItemObject () <NSCoding>
@end


@implementation RideItemObject

- (id)init {
    if( self = [super init] ) {
        self.rideId = @"";
        self.photoUrl = @"";
        self.name = @"";
        self.grantedDate = 0;
        self.startValidDate = 0;
        self.expDate = 0;
        self.read = NO;
        self.isUse = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.rideId = [coder decodeObjectForKey:@"rideId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.grantedDate = [coder decodeIntegerForKey:@"grantedDate"];
        self.startValidDate = [coder decodeIntegerForKey:@"startValidDate"];
        self.expDate = [coder decodeIntegerForKey:@"expDate"];
        self.read = [coder decodeBoolForKey:@"read"];
        self.isUse = [coder decodeBoolForKey:@"isUse"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rideId forKey:@"rideId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.grantedDate forKey:@"grantedDate"];
    [coder encodeInteger:self.startValidDate forKey:@"startValidDate"];
    [coder encodeInteger:self.expDate forKey:@"expDate"];
    [coder encodeBool:self.read forKey:@"read"];
    [coder encodeBool:self.isUse forKey:@"isUse"];
}

@end
