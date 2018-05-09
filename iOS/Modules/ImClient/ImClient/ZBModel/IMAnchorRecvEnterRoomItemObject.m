//
//  IMAnchorRecvEnterRoomItemObject.m
//  livestream
//
//  Created by Max on 2018/4/10
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMAnchorRecvEnterRoomItemObject.h"

@implementation IMAnchorRecvEnterRoomItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.isAnchor = [coder decodeBoolForKey:@"isAnchor"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.userInfo = [coder decodeObjectForKey:@"userInfo"];
        self.pullUrl = [coder decodeObjectForKey:@"pullUrl"];
        self.bugForList = [coder decodeObjectForKey:@"bugForList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeBool:self.isAnchor forKey:@"isAnchor"];
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.userInfo forKey:@"userInfo"];
    [coder encodeObject:self.pullUrl forKey:@"pullUrl"];
    [coder encodeObject:self.bugForList forKey:@"bugForList"];

}


@end
