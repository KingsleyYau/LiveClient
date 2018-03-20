//
//  ZBImControlPushItemObject.m
//  dating
//
//  Created by Alex on 18/03/07.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBImControlPushItemObject.h"
@interface ZBImControlPushItemObject () <NSCoding>
@end


@implementation ZBImControlPushItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.control = [coder decodeIntForKey:@"control"];
        self.manVideoUrl = [coder decodeObjectForKey:@"manVideoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeInt:self.control forKey:@"control"];
    [coder encodeObject:self.manVideoUrl forKey:@"manVideoUrl"];

}

@end
