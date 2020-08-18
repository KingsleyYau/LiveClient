//
//  LSPremiumVideoAccessKeyItemObject.m
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoAccessKeyItemObject.h"
@interface LSPremiumVideoAccessKeyItemObject () <NSCoding>
@end


@implementation LSPremiumVideoAccessKeyItemObject

- (id)init {
    if( self = [super init] ) {
        self.requestId = @"";
        self.premiumVideoInfo = NULL;
        self.emfId = @"";
        self.emfReadStatus = NO;
        self.validTime = 0;
        self.lastSendTime = 0;
        self.currentTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.requestId = [coder decodeObjectForKey:@"requestId"];
        self.premiumVideoInfo = [coder decodeObjectForKey:@"premiumVideoInfo"];
        self.emfId = [coder decodeObjectForKey:@"emfId"];
        self.emfReadStatus = [coder decodeBoolForKey:@"emfReadStatus"];
        self.validTime = [coder decodeIntegerForKey:@"validTime"];
        self.lastSendTime = [coder decodeIntegerForKey:@"lastSendTime"];
        self.currentTime = [coder decodeIntegerForKey:@"currentTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.requestId forKey:@"requestId"];
    [coder encodeObject:self.premiumVideoInfo forKey:@"premiumVideoInfo"];
    [coder encodeObject:self.emfId forKey:@"emfId"];
    [coder encodeBool:self.emfReadStatus forKey:@"emfReadStatus"];
    [coder encodeInteger:self.validTime forKey:@"validTime"];
    [coder encodeInteger:self.lastSendTime forKey:@"lastSendTime"];
    [coder encodeInteger:self.currentTime forKey:@"currentTime"];;
}

@end
