//
//  LSSayHiAllItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiAllItemObject.h"
@interface LSSayHiAllItemObject () <NSCoding>
@end


@implementation LSSayHiAllItemObject

- (id)init {
    if( self = [super init] ) {
        self.totalCount = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.totalCount = [coder decodeIntForKey:@"totalCount"];
        self.list = [coder decodeObjectForKey:@"list"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.totalCount forKey:@"totalCount"];
    [coder encodeObject:self.list forKey:@"list"];

}

@end
