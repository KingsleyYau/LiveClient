//
//  LSSayHiDetailInfoItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiDetailInfoItemObject.h"
@interface LSSayHiDetailInfoItemObject () <NSCoding>
@end


@implementation LSSayHiDetailInfoItemObject

- (id)init {
    if( self = [super init] ) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.detail = [coder decodeObjectForKey:@"detail"];
        self.responseList = [coder decodeObjectForKey:@"responseList"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.detail forKey:@"detail"];
    [coder encodeObject:self.responseList forKey:@"responseList"];

}

@end
