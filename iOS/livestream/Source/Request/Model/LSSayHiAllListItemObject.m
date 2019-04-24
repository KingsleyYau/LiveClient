//
//  LSSayHiAllListItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiAllListItemObject.h"
@interface LSSayHiAllListItemObject () <NSCoding>
@end


@implementation LSSayHiAllListItemObject

- (id)init {
    if( self = [super init] ) {
        self.sayHiId = @"";
        self.anchorId = @"";
        self.nickName = @"";
        self.cover = @"";
        self.avatar = @"";
        self.age = 0;
        self.responseNum = 0;
        self.unreadNum = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.sayHiId = [coder decodeObjectForKey:@"sayHiId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.cover = [coder decodeObjectForKey:@"cover"];
        self.avatar = [coder decodeObjectForKey:@"avatar"];
        self.age = [coder decodeIntForKey:@"age"];
        self.responseNum = [coder decodeIntForKey:@"responseNum"];
        self.unreadNum = [coder decodeIntForKey:@"unreadNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.sayHiId forKey:@"sayHiId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.cover forKey:@"cover"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeInt:self.responseNum forKey:@"responseNum"];
    [coder encodeInt:self.unreadNum forKey:@"unreadNum"];

}

@end
