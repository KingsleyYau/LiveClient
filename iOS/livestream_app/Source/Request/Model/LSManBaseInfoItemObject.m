//
//  LSManBaseInfoItemObject.m
//  dating
//
//  Created by Alex on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSManBaseInfoItemObject.h"
@interface LSManBaseInfoItemObject () <NSCoding>
@end


@implementation LSManBaseInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.userId = @"";
        self.nickName = @"";
        self.nickNameStatus = NICKNAMEVERIFYSTATUS_HANDLDING;
        self.photoUrl = @"";
        self.photoStatus = PHOTOVERIFYSTATUS_HANDLDING;
        self.birthday = @"";
        self.userlevel = 0;
        self.gender = GENDERTYPE_MAN;
        self.userType = USERTYPEA2;
        self.gaUid = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.nickNameStatus = [coder decodeIntForKey:@"nickNameStatus"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.photoStatus = [coder decodeIntForKey:@"photoStatus"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
        self.userlevel = [coder decodeIntForKey:@"userlevel"];
        self.gender = [coder decodeIntForKey:@"gender"];
        self.userType = [coder decodeIntForKey:@"userType"];
        self.gaUid = [coder decodeObjectForKey:@"gaUid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeInt:self.nickNameStatus forKey:@"nickNameStatus"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.photoStatus forKey:@"photoStatus"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
    [coder encodeInt:self.userlevel forKey:@"userlevel"];
    [coder encodeInt:self.gender forKey:@"gender"];
    [coder encodeInt:self.userType forKey:@"userType"];
    [coder encodeObject:self.gaUid forKey:@"gaUid"];

}

@end
