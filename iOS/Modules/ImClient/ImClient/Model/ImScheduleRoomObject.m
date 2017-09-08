//
//  ImScheduleRoomObject.m
//  livestream
//
//  Created by Max on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImScheduleRoomObject.h"

@implementation ImScheduleRoomObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorImg = [coder decodeObjectForKey:@"anchorImg"];
        self.anchorCoverImg = [coder decodeObjectForKey:@"anchorCoverImg"];
        self.canEnterTime = [coder decodeIntegerForKey:@"canEnterTime"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorImg forKey:@"anchorImg"];
    [coder encodeObject:self.anchorCoverImg forKey:@"anchorCoverImg"];
    [coder encodeInteger:self.canEnterTime forKey:@"canEnterTime"];
    [coder encodeObject:self.roomId forKey:@"roomId"];

}


@end
