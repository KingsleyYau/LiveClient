//
//  LSHangoutPrivItemObject.m
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSHangoutPrivItemObject.h"
@interface LSHangoutPrivItemObject () <NSCoding>
@end


@implementation LSHangoutPrivItemObject

- (id)init {
    if( self = [super init] ) {
        self.isHangoutPriv = true;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.isHangoutPriv = [coder decodeBoolForKey:@"isHangoutPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isHangoutPriv forKey:@"isHangoutPriv"];
}

@end
