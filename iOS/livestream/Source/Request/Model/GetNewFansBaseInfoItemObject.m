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
        self.mountId = @"";
        self.mountUrl = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.mountId = [coder decodeObjectForKey:@"mountId"];
        self.mountUrl = [coder decodeObjectForKey:@"mountUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.mountId forKey:@"mountId"];
    [coder encodeObject:self.mountUrl forKey:@"mountUrl"];

}

@end
