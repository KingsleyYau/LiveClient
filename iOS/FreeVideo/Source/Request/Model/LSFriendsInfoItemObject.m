//
//  LSFriendsInfoItemObject.m
//  dating
//
//  Created by Alex on 18/1/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSFriendsInfoItemObject.h"
@interface LSFriendsInfoItemObject () <NSCoding>
@end


@implementation LSFriendsInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.nickName = @"";
        self.anchorImg = @"";
        self.coverImg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.anchorImg = [coder decodeObjectForKey:@"anchorImg"];
        self.coverImg = [coder decodeObjectForKey:@"coverImg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.anchorImg forKey:@"anchorImg"];
    [coder encodeObject:self.coverImg forKey:@"coverImg"];
}

@end
