//
//  IMHangoutRoomItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMHangoutRoomItemObject.h"

@implementation IMHangoutRoomItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.manLevel = [coder decodeIntForKey:@"manLevel"];
        self.manPushPrice = [coder decodeDoubleForKey:@"manPushPrice"];
        self.pushUrl = [coder decodeObjectForKey:@"pushUrl"];
        self.otherAnchorList = [coder decodeObjectForKey:@"otherAnchorList"];
        self.buyforList = [coder decodeObjectForKey:@"buyforList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeInt:self.manLevel forKey:@"manLevel"];
    [coder encodeDouble:self.manPushPrice forKey:@"manPushPrice"];
    [coder encodeObject:self.pushUrl forKey:@"pushUrl"];
    [coder encodeObject:self.otherAnchorList forKey:@"otherAnchorList"];
    [coder encodeObject:self.buyforList forKey:@"buyforList"];

}


@end
