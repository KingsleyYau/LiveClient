//
//  ImLiveRoomObject.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImLiveRoomObject.h"

@implementation ImLiveRoomObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.videoUrls = [coder decodeObjectForKey:@"videoUrls"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.usedVoucher = [coder decodeBoolForKey:@"usedVoucher"];
        self.fansNum = [coder decodeIntForKey:@"fansNum"];
        self.emoTypeList = [coder decodeObjectForKey:@"emoTypeList"];
        self.loveLevel = [coder decodeIntForKey:@"loveLevel"];
        self.rebateInfo = [coder decodeObjectForKey:@"rebateInfo"];
        self.favorite = [coder decodeBoolForKey:@"favorite"];
        self.leftSeconds = [coder decodeIntForKey:@"leftSeconds"];
        self.waitStart = [coder decodeBoolForKey:@"waitStart"];
        self.manPushUrl = [coder decodeObjectForKey:@"manPushUrl"];
        self.manLevel = [coder decodeIntForKey:@"manLevel"];
        self.roomPrice = [coder decodeDoubleForKey:@"roomPrice"];
        self.manPushPrice = [coder decodeDoubleForKey:@"manPushPrice"];
        self.maxFansiNum = [coder decodeIntForKey:@"maxFansiNum"];
        self.honorId = [coder decodeObjectForKey:@"honorId"];
        self.honorImg = [coder decodeObjectForKey:@"honorImg"];
        self.popPrice = [coder decodeDoubleForKey:@"popPrice"];
        self.useCoupon = [coder decodeIntForKey:@"useCoupon"];
        self.shareLink = [coder decodeObjectForKey:@"shareLink"];
        self.liveShowType = [coder decodeIntForKey:@"liveShowType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.videoUrls forKey:@"videoUrls"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeBool:self.usedVoucher forKey:@"usedVoucher"];
    [coder encodeInt:self.fansNum forKey:@"fansNum"];
    [coder encodeObject:self.emoTypeList forKey:@"emoTypeList"];
    [coder encodeInt:self.loveLevel forKey:@"loveLevel"];
    [coder encodeObject:self.rebateInfo forKey:@"rebateInfo"];
    [coder encodeBool:self.favorite forKey:@"favorite"];
    [coder encodeInt:self.leftSeconds forKey:@"leftSeconds"];
    [coder encodeBool:self.waitStart forKey:@"waitStart"];
    [coder encodeObject:self.manPushUrl forKey:@"manPushUrl"];
    [coder encodeInt:self.manLevel forKey:@"manLevel"];
    [coder encodeDouble:self.roomPrice forKey:@"roomPrice"];
    [coder encodeDouble:self.manPushPrice forKey:@"manPushPrice"];
    [coder encodeInt:self.maxFansiNum forKey:@"maxFansiNum"];
    [coder encodeObject:self.honorId forKey:@"honorId"];
    [coder encodeObject:self.honorImg forKey:@"honorImg"];
    [coder encodeDouble:self.popPrice forKey:@"popPrice"];
    [coder encodeInt:self.useCoupon forKey:@"useCoupon"];
    [coder encodeObject:self.shareLink forKey:@"shareLink"];
    [coder encodeInt:self.liveShowType forKey:@"liveShowType"];
}


@end
