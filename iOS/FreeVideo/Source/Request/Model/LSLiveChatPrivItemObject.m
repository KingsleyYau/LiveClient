//
//  LSLiveChatPrivItemObject.m
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLiveChatPrivItemObject.h"
@interface LSLiveChatPrivItemObject () <NSCoding>
@end


@implementation LSLiveChatPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.isLiveChatPriv = true;
        self.liveChatInviteRiskType = LSHTTP_LIVECHATINVITE_RISK_NOLIMIT;
        self.isSendLiveChatPhotoPriv = true;
        self.isSendLiveChatVoicePriv = true;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.isLiveChatPriv = [coder decodeBoolForKey:@"isLiveChatPriv"];
        self.liveChatInviteRiskType = [coder decodeIntForKey:@"liveChatInviteRiskType"];
        self.isSendLiveChatPhotoPriv = [coder decodeBoolForKey:@"isSendLiveChatPhotoPriv"];
        self.isSendLiveChatVoicePriv = [coder decodeBoolForKey:@"isSendLiveChatVoicePriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isLiveChatPriv forKey:@"isLiveChatPriv"];
    [coder encodeInt:self.liveChatInviteRiskType forKey:@"liveChatInviteRiskType"];
    [coder encodeBool:self.isSendLiveChatPhotoPriv forKey:@"isSendLiveChatPhotoPriv"];
    [coder encodeBool:self.isSendLiveChatVoicePriv forKey:@"isSendLiveChatVoicePriv"];
}

@end
