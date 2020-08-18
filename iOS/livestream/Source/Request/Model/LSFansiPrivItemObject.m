//
//  LSFansiPrivItemObject.m
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSFansiPrivItemObject.h"
@interface LSFansiPrivItemObject () <NSCoding>
@end


@implementation LSFansiPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.premiumVideoPriv = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.premiumVideoPriv = [coder decodeBoolForKey:@"premiumVideoPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.premiumVideoPriv forKey:@"premiumVideoPriv"];
}

@end
