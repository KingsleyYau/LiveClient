//
//  LSVoucherAvailableInfoItemObject.m
//  dating
//
//  Created by Alex on 18/1/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSVoucherAvailableInfoItemObject.h"
@interface LSVoucherAvailableInfoItemObject () <NSCoding>
@end


@implementation LSVoucherAvailableInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.onlypublicExpTime = 0;
        self.onlyprivateExpTime = 0;
        self.onlypublicNewExpTime = 0;
        self.onlyprivateNewExpTime = 0;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.onlypublicExpTime = [coder decodeIntegerForKey:@"onlypublicExpTime"];
        self.onlyprivateExpTime = [coder decodeIntegerForKey:@"onlyprivateExpTime"];
        self.bindAnchor = [coder decodeObjectForKey:@"bindAnchor"];
        self.onlypublicNewExpTime = [coder decodeIntegerForKey:@"onlypublicNewExpTime"];
        self.onlyprivateNewExpTime = [coder decodeIntegerForKey:@"onlyprivateNewExpTime"];
        self.watchedAnchor = [coder decodeObjectForKey:@"watchedAnchor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.onlypublicExpTime forKey:@"onlypublicExpTime"];
    [coder encodeInteger:self.onlyprivateExpTime forKey:@"onlyprivateExpTime"];
    [coder encodeObject:self.bindAnchor forKey:@"bindAnchor"];
    [coder encodeInteger:self.onlypublicNewExpTime forKey:@"onlypublicNewExpTime"];
    [coder encodeInteger:self.onlyprivateNewExpTime forKey:@"onlyprivateNewExpTime"];
    [coder encodeObject:self.watchedAnchor forKey:@"watchedAnchor"];
}

@end
