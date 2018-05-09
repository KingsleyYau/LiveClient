//
//  IMRecvLeaveRoomItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMRecvLeaveRoomItemObject.h"

@implementation IMRecvLeaveRoomItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.isAnchor = [coder decodeBoolForKey:@"isAnchor"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.errNo = [coder decodeIntForKey:@"errNo"];
        self.errMsg = [coder decodeObjectForKey:@"errMsg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeBool:self.isAnchor forKey:@"isAnchor"];
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.errNo forKey:@"errNo"];
    [coder encodeObject:self.errMsg forKey:@"errMsg"];

}


@end
