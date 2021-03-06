//
//  LSLoginItemObject.m
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLoginItemObject.h"
@interface LSLoginItemObject () <NSCoding>
@end


@implementation LSLoginItemObject

- (id)init
{
    self = [super init];
    if (self) {
        self.userId = @"";
        self.token = @"";
        self.nickName = @"";
        self.level = 0;
        self.experience = 0;
        self.photoUrl = @"";
        self.isPushAd = NO;
        self.svrList = @[];
        self.userType = USERTYPEA2;
        self.qnMainAdUrl = @"";
    }
    return self;
}

- (id)initWithUser:(LSManBaseInfoItemObject *)obj andToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.userId = obj.userId;
        self.token = token;
        self.nickName = obj.nickName;
        self.level = 0;
        self.experience = 0;
        self.photoUrl = obj.photoUrl;
        self.isPushAd = NO;
        self.svrList = @[];
        self.userType = USERTYPEA2;
        self.qnMainAdUrl = @"";
        self.qnMainAdTitle = @"";
        self.qnMainAdId = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.level = [coder decodeIntForKey:@"level"];
        self.experience = [coder decodeIntForKey:@"experience"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.isPushAd = [coder decodeBoolForKey:@"isPushAd"];
        self.svrList = [coder decodeObjectForKey:@"svrList"];
        self.userType = [coder decodeIntForKey:@"userType"];
        self.qnMainAdUrl = [coder decodeObjectForKey:@"qnMainAdUrl"];
        self.qnMainAdTitle = [coder decodeObjectForKey:@"qnMainAdTitle"];
        self.qnMainAdId = [coder decodeObjectForKey:@"qnMainAdId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.token forKey:@"email"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeInt:self.experience forKey:@"experience"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeBool:self.isPushAd forKey:@"isPushAd"];
    [coder encodeObject:self.svrList forKey:@"svrList"];
    [coder encodeInt:self.userType forKey:@"userType"];
    [coder encodeObject:self.qnMainAdUrl forKey:@"qnMainAdUrl"];
    [coder encodeObject:self.qnMainAdTitle forKey:@"qnMainAdTitle"];
    [coder encodeObject:self.qnMainAdId forKey:@"qnMainAdId"];

}

@end
