//
//  LSLoginItemObject.m
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLoginItemObject.h"
@interface LSLoginItemObject () <NSCoding>
@end


@implementation LSLoginItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.level = [coder decodeIntForKey:@"level"];
        self.experience = [coder decodeIntForKey:@"experience"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.isPushAd = [coder decodeBoolForKey:@"isPushAd"];
        self.svrList = [coder decodeObjectForKey:@"svrList"];
        self.userType = [coder decodeIntForKey:@"userType"];
//        self.qnMainAdUrl = [coder decodeObjectForKey:@"qnMainAdUrl"];
//        self.qnMainAdTitle = [coder decodeObjectForKey:@"qnMainAdTitle"];
//        self.qnMainAdId = [coder decodeObjectForKey:@"qnMainAdId"];
        self.gaUid = [coder decodeObjectForKey:@"gaUid"];
        self.sessionId = [coder decodeObjectForKey:@"sessionId"];
        self.isLiveChatRisk = [coder decodeBoolForKey:@"isLiveChatRisk"];
//        self.isHangoutRisk = [coder decodeBoolForKey:@"isHangoutRisk"];
//        self.liveChatInviteRiskType = [coder decodeIntForKey:@"liveChatInviteRiskType"];
//        self.mailPriv = [coder decodeObjectForKey:@"mailPriv"];
        self.userPriv = [coder decodeObjectForKey:@"userPriv"];
        self.isGiftFlowerSwitch = [coder decodeBoolForKey:@"isGiftFlowerSwitch"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.token forKey:@"email"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeInt:self.experience forKey:@"experience"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeBool:self.isPushAd forKey:@"isPushAd"];
    [coder encodeObject:self.svrList forKey:@"svrList"];
    [coder encodeInt:self.userType forKey:@"userType"];
//    [coder encodeObject:self.qnMainAdUrl forKey:@"qnMainAdUrl"];
//    [coder encodeObject:self.qnMainAdTitle forKey:@"qnMainAdTitle"];
//    [coder encodeObject:self.qnMainAdId forKey:@"qnMainAdId"];
    [coder encodeObject:self.gaUid forKey:@"gaUid"];
    [coder encodeObject:self.sessionId forKey:@"sessionId"];
    [coder encodeBool:self.isLiveChatRisk forKey:@"isLiveChatRisk"];
//    [coder encodeBool:self.isHangoutRisk forKey:@"isHangoutRisk"];
//    [coder encodeInt:self.liveChatInviteRiskType forKey:@"liveChatInviteRiskType"];
//    [coder encodeObject:self.mailPriv forKey:@"mailPriv"];
    [coder encodeObject:self.userPriv forKey:@"userPriv"];
    [coder encodeBool:self.isGiftFlowerSwitch forKey:@"isGiftFlowerSwitch"];
}

@end
