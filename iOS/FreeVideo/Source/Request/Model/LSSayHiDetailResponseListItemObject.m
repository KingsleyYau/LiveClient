//
//  LSSayHiDetailResponseListItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiDetailResponseListItemObject.h"
@interface LSSayHiDetailResponseListItemObject () <NSCoding>
@end


@implementation LSSayHiDetailResponseListItemObject

- (id)init {
    if( self = [super init] ) {
        self.responseId = @"";
        self.responseTime = 0;
        self.simpleContent = @"";
        self.content = @"";
        self.isFree = NO;
        self.hasRead = NO;
        self.hasImg = NO;
        self.img = @"";
        self.type = SayHiDetailLoadingType_None;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.responseId = [coder decodeObjectForKey:@"responseId"];
        self.responseTime = [coder decodeIntegerForKey:@"responseTime"];
        self.simpleContent = [coder decodeObjectForKey:@"simpleContent"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.isFree = [coder decodeBoolForKey:@"isFree"];
        self.hasRead = [coder decodeBoolForKey:@"hasRead"];
        self.hasImg = [coder decodeBoolForKey:@"hasImg"];
        self.img = [coder decodeObjectForKey:@"img"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.responseId forKey:@"responseId"];
    [coder encodeInteger:self.responseTime forKey:@"responseTime"];
    [coder encodeObject:self.simpleContent forKey:@"simpleContent"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.isFree forKey:@"isFree"];
    [coder encodeBool:self.hasRead forKey:@"hasRead"];
    [coder encodeBool:self.hasImg forKey:@"hasImg"];
    [coder encodeObject:self.img forKey:@"img"];
}

@end
