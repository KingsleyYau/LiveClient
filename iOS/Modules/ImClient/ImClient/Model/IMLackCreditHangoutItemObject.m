//
//  IMLackCreditHangoutItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMLackCreditHangoutItemObject.h"

@implementation IMLackCreditHangoutItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.errNo = [coder decodeIntForKey:@"errNo"];
        self.errMsg = [coder decodeObjectForKey:@"errMsg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    self.errNo = [coder decodeIntForKey:@"errNo"];
    [coder encodeObject:self.errMsg forKey:@"errMsg"];

}


@end
