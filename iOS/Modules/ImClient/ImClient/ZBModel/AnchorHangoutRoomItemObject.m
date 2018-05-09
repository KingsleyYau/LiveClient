//
//  AnchorHangoutRoomItemObject.m
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "AnchorHangoutRoomItemObject.h"

@implementation AnchorHangoutRoomItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.manId = [coder decodeObjectForKey:@"manId"];
        self.manNickName = [coder decodeObjectForKey:@"manNickName"];
        self.manPhotoUrl = [coder decodeObjectForKey:@"manPhotoUrl"];
        self.manLevel = [coder decodeIntForKey:@"manLevel"];
        self.manVideoUrl = [coder decodeObjectForKey:@"manVideoUrl"];
        self.pushUrl = [coder decodeObjectForKey:@"pushUrl"];
        self.otherAnchorList = [coder decodeObjectForKey:@"otherAnchorList"];
        self.buyforList = [coder decodeObjectForKey:@"buyforList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeObject:self.manId forKey:@"manId"];
    [coder encodeObject:self.manNickName forKey:@"manNickName"];
    [coder encodeObject:self.manPhotoUrl forKey:@"manPhotoUrl"];
    [coder encodeInt:self.manLevel forKey:@"manLevel"];
    [coder encodeObject:self.manVideoUrl forKey:@"manVideoUrl"];
    [coder encodeObject:self.pushUrl forKey:@"pushUrl"];
    [coder encodeObject:self.otherAnchorList forKey:@"otherAnchorList"];
    [coder encodeObject:self.buyforList forKey:@"buyforList"];

}


@end
