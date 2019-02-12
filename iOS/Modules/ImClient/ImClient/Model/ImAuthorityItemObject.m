//
//  ImAuthorityItemObject.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImAuthorityItemObject.h"

@implementation ImAuthorityItemObject

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
