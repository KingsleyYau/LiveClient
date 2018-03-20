//
//  LSUserInfoItemObject.m
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSUserInfoItemObject.h"
@interface LSUserInfoItemObject () <NSCoding>
@end


@implementation LSUserInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.userId = @"";
        self.nickName = @"";
        self.photoUrl = @"";
        self.age = 0;
        self.country = @"";
        self.userLevel = 0;
        self.isOnline = NO;
        self.isAnchor = NO;
        self.leftCredit = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
        self.userLevel = [coder decodeIntForKey:@"userLevel"];
        self.isOnline = [coder decodeBoolForKey:@"isOnline"];
        self.isAnchor = [coder decodeBoolForKey:@"isAnchor"];
        self.leftCredit = [coder decodeDoubleForKey:@"leftCredit"];
        self.anchorInfo = [coder decodeObjectForKey:@"anchorInfo"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];
    [coder encodeInt:self.userLevel forKey:@"userLevel"];
    [coder encodeBool:self.isOnline forKey:@"isOnline"];
    [coder encodeBool:self.isAnchor forKey:@"isAnchor"];
    [coder encodeDouble:self.leftCredit forKey:@"leftCredit"];
    [coder encodeObject:self.anchorInfo forKey:@"anchorInfo"];
}

@end
