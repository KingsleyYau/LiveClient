//
//  IMAnchorKnockRequestItemObject.m
//  livestream
//
//  Created by Max on 2018/4/10
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorKnockRequestItemObject.h"

@implementation IMAnchorKnockRequestItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.knockId = [coder decodeObjectForKey:@"knockId"];
        self.type = [coder decodeIntForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.knockId forKey:@"knockId"];
    [coder encodeInt:self.type forKey:@"type"];

}


@end
