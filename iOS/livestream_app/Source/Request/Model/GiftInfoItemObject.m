//
//  GiftInfoItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftInfoItemObject.h"
@interface GiftInfoItemObject () <NSCoding>
@end


@implementation GiftInfoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.smallImgUrl = [coder decodeObjectForKey:@"smallImgUrl"];
        self.middleImgUrl = [coder decodeObjectForKey:@"middleImgUrl"];
        self.bigImgUrl = [coder decodeObjectForKey:@"bigImgUrl"];
        self.srcFlashUrl = [coder decodeObjectForKey:@"srcFlashUrl"];
        self.srcwebpUrl = [coder decodeObjectForKey:@"srcwebpUrl"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.multiClick = [coder decodeBoolForKey:@"multiClick"];
        self.type = (GiftType) [coder decodeIntForKey:@"type"];
        self.level = [coder decodeIntForKey:@"level"];
        self.loveLevel = [coder decodeIntForKey:@"loveLevel"];
        self.sendNumList = [coder decodeObjectForKey:@"sendNumList"];
        self.updateTime = [coder decodeIntegerForKey:@"updateTime"];
        self.playTime = [coder decodeIntForKey:@"playTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId  forKey:@"giftId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.smallImgUrl  forKey:@"smallImgUrl"];
    [coder encodeObject:self.middleImgUrl  forKey:@"middleImgUrl"];
    [coder encodeObject:self.bigImgUrl  forKey:@"bigImgUrl"];
    [coder encodeObject:self.srcFlashUrl forKey:@"srcFlashUrl"];
    [coder encodeObject:self.srcwebpUrl  forKey:@"srcwebpUrl"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeBool:self.multiClick forKey:@"multiClick"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeInt:self.loveLevel forKey:@"loveLevel"];
    [coder encodeObject:self.sendNumList forKey:@"sendNumList"];
    [coder encodeInteger:self.updateTime forKey:@"updateTime"];
    [coder encodeInt:self.playTime forKey:@"playTime"];
}

@end
