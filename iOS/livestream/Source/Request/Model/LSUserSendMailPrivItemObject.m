//
//  LSUserSendMailPrivItemObject.m
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSUserSendMailPrivItemObject.h"
@interface LSUserSendMailPrivItemObject () <NSCoding>
@end


@implementation LSUserSendMailPrivItemObject

- (id)init {
    if( self = [super init] ) {
        
        self.mailSendPriv = LSSENDIMGRISKTYPE_NORMAL;
        self.maxImg = 0;
        self.postStampMsg = @"";
        self.coinMsg = @"";
        self.quickPostStampMsg = @"";
        self.quickCoinMsg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.mailSendPriv = [coder decodeIntForKey:@"mailSendPriv"];
        self.maxImg = [coder decodeIntForKey:@"maxImg"];
        self.postStampMsg = [coder decodeObjectForKey:@"postStampMsg"];
        self.coinMsg = [coder decodeObjectForKey:@"coinMsg"];
        self.quickPostStampMsg = [coder decodeObjectForKey:@"quickPostStampMsg"];
        self.quickCoinMsg = [coder decodeObjectForKey:@"quickCoinMsg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.mailSendPriv forKey:@"mailSendPriv"];
    [coder encodeInt:self.maxImg forKey:@"maxImg"];
    [coder encodeObject:self.postStampMsg forKey:@"postStampMsg"];
    [coder encodeObject:self.coinMsg forKey:@"coinMsg"];
    [coder encodeObject:self.quickPostStampMsg forKey:@"quickPostStampMsg"];
    [coder encodeObject:self.quickCoinMsg forKey:@"quickCoinMsg"];
}

@end
