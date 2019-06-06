//
//  RideItemObject.m
//  dating
//
//  Created by Alex on 17/10/13.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSvrItemObject.h"
@interface LSSvrItemObject () <NSCoding>
@end


@implementation LSSvrItemObject

- (id)init {
    if( self = [super init] ) {
        self.svrId = @"";
        self.tUrl = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.svrId = [coder decodeObjectForKey:@"svrId"];
        self.tUrl = [coder decodeObjectForKey:@"tUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.svrId forKey:@"svrId"];
    [coder encodeObject:self.tUrl forKey:@"tUrl"];
}

@end
