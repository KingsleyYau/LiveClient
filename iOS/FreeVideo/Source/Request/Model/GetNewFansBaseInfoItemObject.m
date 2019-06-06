//
//  GetNewFansBaseInfoItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetNewFansBaseInfoItemObject.h"
@interface GetNewFansBaseInfoItemObject () <NSCoding>
@end


@implementation GetNewFansBaseInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.nickName = @"";
        self.photoUrl = @"";
        self.riderId = @"";
        self.riderName = @"";
        self.riderUrl = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.riderId = [coder decodeObjectForKey:@"riderId"];
        self.riderName = [coder decodeObjectForKey:@"riderName"];
        self.riderUrl = [coder decodeObjectForKey:@"riderUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.riderId forKey:@"riderId"];
    [coder encodeObject:self.riderName forKey:@"riderName"];
    [coder encodeObject:self.riderUrl forKey:@"riderUrl"];

}

@end
