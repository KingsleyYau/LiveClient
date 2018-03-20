//
//  ImLoginRoomObject.m
//  livestream
//
//  Created by Max on 2017/11/03.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ZBImLoginRoomObject.h"

@implementation ZBImLoginRoomObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];

}


@end
