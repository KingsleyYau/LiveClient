//
//  ZBImLiveRoomObject.m
//  livestream
//
//  Created by Max on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ZBImLiveRoomObject.h"

@implementation ZBImLiveRoomObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.pushUrl = [coder decodeObjectForKey:@"pushUrl"];
        self.leftSeconds = [coder decodeIntForKey:@"leftSeconds"];
        self.maxFansiNum = [coder decodeIntForKey:@"maxFansiNum"];
        self.pullUrl = [coder decodeObjectForKey:@"pullUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeObject:self.pushUrl forKey:@"pushUrl"];
    [coder encodeInt:self.leftSeconds forKey:@"leftSeconds"];
    [coder encodeInt:self.maxFansiNum forKey:@"maxFansiNum"];
    [coder encodeObject:self.pullUrl forKey:@"pullUrl"];

}


@end
