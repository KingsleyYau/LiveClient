//
//  IMAnchorRecommendHangoutItemObject.m
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorRecommendHangoutItemObject.h"

@implementation IMAnchorRecommendHangoutItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.friendId = [coder decodeObjectForKey:@"friendId"];
        self.friendNickName = [coder decodeObjectForKey:@"friendNickName"];
        self.friendPhotoUrl = [coder decodeObjectForKey:@"friendPhotoUrl"];
        self.friendAge = [coder decodeIntForKey:@"friendAge"];
        self.friendCountry = [coder decodeObjectForKey:@"friendCountry"];
        self.recommendId = [coder decodeObjectForKey:@"recommendId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.friendId forKey:@"friendId"];
    [coder encodeObject:self.friendNickName forKey:@"friendNickName"];
    [coder encodeObject:self.friendPhotoUrl forKey:@"friendPhotoUrl"];
    [coder encodeInt:self.friendAge forKey:@"friendAge"];
    [coder encodeObject:self.friendCountry forKey:@"friendCountry"];
    [coder encodeObject:self.recommendId forKey:@"recommendId"];

}


@end
