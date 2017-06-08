//
//  LoginItemObject.m
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LoginItemObject.h"
@interface LoginItemObject () <NSCoding>
@end


@implementation LoginItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.level = [coder decodeIntForKey:@"level"];
        self.country = [coder decodeObjectForKey:@"country"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.sign = [coder decodeObjectForKey:@"sign"];
        self.anchor = [coder decodeBoolForKey:@"anchor"];
        self.modifyinfo = [coder decodeBoolForKey:@"modifyinfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.token forKey:@"email"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeObject:self.country forKey:@"country"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.sign forKey:@"sign"];
    [coder encodeBool:self.anchor forKey:@"anchor"];
    [coder encodeBool:self.modifyinfo forKey:@"modifyinfo"];
}

@end
