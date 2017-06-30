//
//  LiveRoomGiftItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LiveRoomGiftItemObject.h"
@interface LiveRoomGiftItemObject () <NSCoding>
@end


@implementation LiveRoomGiftItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.smallImgUrl = [coder decodeObjectForKey:@"smallImgUrl"];
        self.imgUrl = [coder decodeObjectForKey:@"imgUrl"];
        self.srcUrl = [coder decodeObjectForKey:@"srcUrl"];
        self.coins = [coder decodeDoubleForKey:@"coins"];
        self.multi_click = [coder decodeBoolForKey:@"multi_click"];
        self.type = (GiftType) [coder decodeIntForKey:@"type"];
        self.update_time = [coder decodeIntForKey:@"update_time"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId  forKey:@"giftId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.smallImgUrl  forKey:@"smallImgUrl"];
    [coder encodeObject:self.imgUrl forKey:@"imgUrl"];
    [coder encodeObject:self.srcUrl  forKey:@"srcUrl"];
    [coder encodeDouble:self.coins forKey:@"coins"];
    [coder encodeBool:self.multi_click forKey:@"multi_click"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeInt:self.update_time forKey:@"update_time"];
}

@end
