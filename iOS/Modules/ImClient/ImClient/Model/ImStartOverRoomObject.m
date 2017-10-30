//
//  ImStartOverRoomObject.m
//  dating
//
//  Created by Alex on 17/09/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ImStartOverRoomObject.h"
@interface ImStartOverRoomObject () <NSCoding>
@end


@implementation ImStartOverRoomObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.leftSeconds = [coder decodeIntForKey:@"leftSeconds"];
        self.playUrl = [coder decodeObjectForKey:@"playUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeInt:self.leftSeconds forKey:@"leftSeconds"];
    [coder encodeObject:self.playUrl forKey:@"playUrl"];

}

@end
