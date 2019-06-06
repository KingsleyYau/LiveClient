//
//  LSHttpAuthorityItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHttpAuthorityItemObject.h"
@interface LSHttpAuthorityItemObject () <NSCoding>
@end


@implementation LSHttpAuthorityItemObject
- (id)init {
    if( self = [super init] ) {
        self.isHasOneOnOneAuth = YES;
        self.isHasBookingAuth = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.isHasOneOnOneAuth = [coder decodeBoolForKey:@"isHasOneOnOneAuth"];
        self.isHasBookingAuth = [coder decodeBoolForKey:@"isHasBookingAuth"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.isHasOneOnOneAuth forKey:@"isHasOneOnOneAuth"];
    [coder encodeBool:self.isHasBookingAuth forKey:@"isHasBookingAuth"];
}

@end
