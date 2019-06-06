//
//  LSUserPrivItemObject.m
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSUserPrivItemObject.h"
@interface LSUserPrivItemObject () <NSCoding>
@end


@implementation LSUserPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.isSayHiPriv = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.liveChatPriv = [coder decodeObjectForKey:@"liveChatPriv"];
        self.mailPriv = [coder decodeObjectForKey:@"mailPriv"];
        self.hangoutPriv = [coder decodeObjectForKey:@"hangoutPriv"];
        self.isSayHiPriv = [coder decodeBoolForKey:@"isSayHiPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.liveChatPriv forKey:@"liveChatPriv"];
    [coder encodeObject:self.mailPriv forKey:@"mailPriv"];
    [coder encodeObject:self.hangoutPriv forKey:@"hangoutPriv"];
    [coder encodeBool:self.isSayHiPriv forKey:@"isSayHiPriv"];
}

@end
