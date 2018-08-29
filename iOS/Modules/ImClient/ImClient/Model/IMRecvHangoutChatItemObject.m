//
//  IMRecvHangoutChatItemObject.m
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMRecvHangoutChatItemObject.h"

@implementation IMRecvHangoutChatItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.level = [coder decodeIntForKey:@"level"];
        self.fromId = [coder decodeObjectForKey:@"fromId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.msg = [coder decodeObjectForKey:@"msg"];
        self.honorUrl = [coder decodeObjectForKey:@"honorUrl"];
        self.at = [coder decodeObjectForKey:@"at"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeObject:self.fromId forKey:@"fromId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.msg forKey:@"msg"];
    [coder encodeObject:self.honorUrl forKey:@"honorUrl"];
    [coder encodeObject:self.at forKey:@"at"];

}


@end
