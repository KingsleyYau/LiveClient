//
//  ZBGetNewFansBaseInfoItemObject.m
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBGetNewFansBaseInfoItemObject.h"
@interface ZBGetNewFansBaseInfoItemObject () <NSCoding>
@end


@implementation ZBGetNewFansBaseInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.userId = @"";
        self.nickName = @"";
        self.photoUrl = @"";
        self.riderId = @"";
        self.riderName = @"";
        self.riderUrl = @"";
        self.level = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.riderId = [coder decodeObjectForKey:@"riderId"];
        self.riderName = [coder decodeObjectForKey:@"riderName"];
        self.riderUrl = [coder decodeObjectForKey:@"riderUrl"];
        self.level = [coder decodeIntForKey:@"level"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.riderId forKey:@"riderId"];
    [coder encodeObject:self.riderName forKey:@"riderName"];
    [coder encodeObject:self.riderUrl forKey:@"riderUrl"];
    [coder encodeInt:self.level forKey:@"level"];

}

@end
