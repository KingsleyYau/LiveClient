//
//  IMLivingAnchorItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMLivingAnchorItemObject.h"
@implementation IMLivingAnchorItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.anchorStatus = [coder decodeIntForKey:@"anchorStatus"];
        self.inviteId = [coder decodeObjectForKey:@"inviteId"];
        self.leftSeconds = [coder decodeIntForKey:@"leftSeconds"];
        self.loveLevel = [coder decodeIntForKey:@"loveLevel"];
        self.videoUrl = [coder decodeObjectForKey:@"videoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.anchorStatus forKey:@"anchorStatus"];
    [coder encodeObject:self.inviteId forKey:@"inviteId"];
    [coder encodeInt:self.leftSeconds forKey:@"leftSeconds"];
    [coder encodeInt:self.loveLevel forKey:@"loveLevel"];
    [coder encodeObject:self.videoUrl forKey:@"videoUrl"];

}


@end
