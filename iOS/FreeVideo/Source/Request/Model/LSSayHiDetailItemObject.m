//
//  LSSayHiDetailItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiDetailItemObject.h"
@interface LSSayHiDetailItemObject () <NSCoding>
@end


@implementation LSSayHiDetailItemObject

- (id)init {
    if( self = [super init] ) {
        self.sayHiId = @"";
        self.anchorId = @"";
        self.nickName = @"";
        self.cover = @"";
        self.avatar = @"";
        self.age = 0;
        self.sendTime = 0;
        self.text = @"";
        self.img = @"";
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
        self.sendTime = [coder decodeIntegerForKey:@"sendTime"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.img = [coder decodeObjectForKey:@"img"];
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
    [coder encodeInteger:self.sendTime forKey:@"sendTime"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.img forKey:@"img"];
    [coder encodeInt:self.responseNum forKey:@"responseNum"];
    [coder encodeInt:self.unreadNum forKey:@"unreadNum"];
}

@end
