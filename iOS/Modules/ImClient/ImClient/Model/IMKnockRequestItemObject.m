//
//  IMKnockRequestItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMKnockRequestItemObject.h"

@implementation IMKnockRequestItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
        self.knockId = [coder decodeObjectForKey:@"knockId"];
        self.expire = [coder decodeIntForKey:@"expire"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    self.age = [coder decodeIntForKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];
    [coder encodeObject:self.knockId forKey:@"knockId"];
    [coder encodeInt:self.expire forKey:@"expire"];

}


@end
