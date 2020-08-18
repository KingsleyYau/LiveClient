//
//  LSFansiInfoItemObject.m
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSFansiInfoItemObject.h"
@interface LSFansiInfoItemObject () <NSCoding>
@end


@implementation LSFansiInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.fansiPriv = NULL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.fansiPriv = [coder decodeObjectForKey:@"anchorPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fansiPriv forKey:@"anchorPriv"];
}

@end
