//
//  LSSayHiResponseListItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiResponseListItemObject.h"
@interface LSSayHiResponseListItemObject () <NSCoding>
@end


@implementation LSSayHiResponseListItemObject

- (id)init {
    if( self = [super init] ) {
        self.sayHiId = @"";
        self.responseId = @"";
        self.anchorId = @"";
        self.nickName = @"";
        self.cover = @"";
        self.avatar = @"";
        self.age = 0;
        self.responseTime = 0;
        self.content = @"";
        self.hasImg = NO;
        self.hasRead = NO;
        self.isFree = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.sayHiId = [coder decodeObjectForKey:@"sayHiId"];
        self.responseId = [coder decodeObjectForKey:@"responseId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.cover = [coder decodeObjectForKey:@"cover"];
        self.avatar = [coder decodeObjectForKey:@"avatar"];
        self.age = [coder decodeIntForKey:@"age"];
        self.responseTime = [coder decodeIntegerForKey:@"responseTime"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.hasImg = [coder decodeBoolForKey:@"hasImg"];
        self.hasRead = [coder decodeBoolForKey:@"hasRead"];
        self.isFree = [coder decodeBoolForKey:@"isFree"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.sayHiId forKey:@"sayHiId"];
    [coder encodeObject:self.responseId forKey:@"responseId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.cover forKey:@"cover"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeInteger:self.responseTime forKey:@"responseTime"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.hasImg forKey:@"hasImg"];
    [coder encodeBool:self.hasRead forKey:@"hasRead"];
    [coder encodeBool:self.isFree forKey:@"isFree"];
}

@end
