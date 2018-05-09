//
//  IMRecvHangoutGiftItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMRecvHangoutGiftItemObject.h"

@implementation IMRecvHangoutGiftItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.fromId = [coder decodeObjectForKey:@"fromId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.toUid = [coder decodeObjectForKey:@"toUid"];
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
        self.isMultiClick = [coder decodeBoolForKey:@"isMultiClick"];
        self.multiClickStart = [coder decodeIntForKey:@"multiClickStart"];
        self.multiClickEnd = [coder decodeIntForKey:@"multiClickEnd"];
        self.multiClickId = [coder decodeIntForKey:@"multiClickId"];
        self.isPrivate = [coder decodeBoolForKey:@"isPrivate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.fromId forKey:@"fromId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.toUid forKey:@"toUid"];
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];
    [coder encodeBool:self.isMultiClick forKey:@"isMultiClick"];
    [coder encodeInt:self.multiClickStart forKey:@"multiClickStart"];
    [coder encodeInt:self.multiClickEnd forKey:@"multiClickEnd"];
    [coder encodeInt:self.multiClickId forKey:@"multiClickId"];
    [coder encodeBool:self.isPrivate forKey:@"isPrivate"];

}


@end
