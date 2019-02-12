//
//  ConfigItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ConfigItemObject.h"
@interface ConfigItemObject () <NSCoding>
@end


@implementation ConfigItemObject

- (id)init {
    if( self = [super init] ) {
        self.imSvrUrl = @"";
        self.httpSvrUrl = @"";
        self.addCreditsUrl = @"";
        self.anchorPage = @"";
        self.userLevel = @"";
        self.intimacy = @"";
        self.userProtocol = @"";
        self.showDetailPage = @"";
        self.showDescription = @"";
        self.hangoutCredirMsg = @"";
        self.hangoutCreditPrice = 0.0;
        self.loiH5Url = @"";
        self.emfH5Url = @"";
        self.pmStartNotice = @"";
        self.postStampUrl = @"";
        self.httpSvrMobileUrl = @"";
        
        self.sendLetter = @"";
        
        self.socketHost = @"";
        self.socketHostDomain = @"l";
        self.socketPort = 0;
        self.webSite = @"";
        self.appSite = @"";
        self.chatVoiceHostUrl =  @"";
        self.minBalanceForChat = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.imSvrUrl = [coder decodeObjectForKey:@"imSvrUrl"];
        self.httpSvrUrl = [coder decodeObjectForKey:@"httpSvrUrl"];
        self.addCreditsUrl = [coder decodeObjectForKey:@"addCreditsUrl"];
        self.anchorPage = [coder decodeObjectForKey:@"anchorPage"];
        self.userLevel = [coder decodeObjectForKey:@"userLevel"];
        self.intimacy = [coder decodeObjectForKey:@"intimacy"];
        self.userProtocol = [coder decodeObjectForKey:@"userProtocol"];
        self.showDetailPage = [coder decodeObjectForKey:@"showDetailPage"];
        self.showDescription = [coder decodeObjectForKey:@"showDescription"];
        self.hangoutCredirMsg = [coder decodeObjectForKey:@"hangoutCredirMsg"];
        self.hangoutCreditPrice = [coder decodeDoubleForKey:@"hangoutCreditPrice"];
        self.loiH5Url = [coder decodeObjectForKey:@"loiH5Url"];
        self.emfH5Url = [coder decodeObjectForKey:@"emfH5Url"];
        self.pmStartNotice = [coder decodeObjectForKey:@"pmStartNotice"];
        self.postStampUrl = [coder decodeObjectForKey:@"postStampUrl"];
        self.httpSvrMobileUrl = [coder decodeObjectForKey:@"httpSvrMobileUrl"];
        self.sendLetter = [coder decodeObjectForKey:@"sendLetter"];
        self.socketHost = [coder decodeObjectForKey:@"socketHost"];
        self.socketHostDomain = [coder decodeObjectForKey:@"socketHostDomain"];
        self.socketPort = [coder decodeIntForKey:@"socketPort"];
        self.webSite = [coder decodeObjectForKey:@"webSite"];
        self.appSite = [coder decodeObjectForKey:@"appSite"];
        self.chatVoiceHostUrl = [coder decodeObjectForKey:@"chatVoiceHostUrl"];
        self.minBalanceForChat = [coder decodeDoubleForKey:@"minBalanceForChat"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.imSvrUrl forKey:@"imSvrUrl"];
    [coder encodeObject:self.httpSvrUrl forKey:@"httpSvrUrl"];
    [coder encodeObject:self.addCreditsUrl forKey:@"addCreditsUrl"];
    [coder encodeObject:self.anchorPage forKey:@"anchorPage"];
    [coder encodeObject:self.userLevel forKey:@"userLevel"];
    [coder encodeObject:self.intimacy forKey:@"intimacy"];
    [coder encodeObject:self.userProtocol forKey:@"userProtocol"];
    [coder encodeObject:self.showDetailPage forKey:@"showDetailPage"];
    [coder encodeObject:self.showDescription forKey:@"showDescription"];
    [coder encodeObject:self.hangoutCredirMsg forKey:@"hangoutCredirMsg"];
    [coder encodeDouble:self.hangoutCreditPrice forKey:@"hangoutCreditPrice"];
    [coder encodeObject:self.loiH5Url forKey:@"loiH5Url"];
    [coder encodeObject:self.emfH5Url forKey:@"emfH5Url"];
    [coder encodeObject:self.pmStartNotice forKey:@"pmStartNotice"];
    [coder encodeObject:self.postStampUrl forKey:@"postStampUrl"];
    [coder encodeObject:self.httpSvrMobileUrl forKey:@"httpSvrMobileUrl"];
    [coder encodeObject:self.sendLetter forKey:@"sendLetter"];
    [coder encodeObject:self.socketHost forKey:@"socketHost"];
    [coder encodeObject:self.socketHostDomain forKey:@"socketHostDomain"];
    [coder encodeInt:self.socketPort forKey:@"socketPort"];
    [coder encodeObject:self.webSite forKey:@"webSite"];
    [coder encodeObject:self.appSite forKey:@"appSite"];
    [coder encodeObject:self.chatVoiceHostUrl forKey:@"chatVoiceHostUrl"];
    [coder encodeDouble:self.minBalanceForChat forKey:@"minBalanceForChat"];

}

@end
