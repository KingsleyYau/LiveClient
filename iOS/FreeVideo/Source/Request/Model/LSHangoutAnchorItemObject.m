//
//  LSHangoutAnchorItemObject.m
//  dating
//
//  Created by Alex on 18/4/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSHangoutAnchorItemObject.h"
@interface LSHangoutAnchorItemObject () <NSCoding>
@end


@implementation LSHangoutAnchorItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.nickName = @"";
        self.photoUrl = @"";
        self.age = 0;
        self.country = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];
}

@end
