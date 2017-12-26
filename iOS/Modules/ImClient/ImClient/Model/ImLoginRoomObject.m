//
//  ImLoginRoomObject.m
//  livestream
//
//  Created by Max on 2017/11/03.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImLoginRoomObject.h"

@implementation ImLoginRoomObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];

}


@end
