//
//  LSMyCartItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSMyCartItemObject.h"
@interface LSMyCartItemObject () <NSCoding>
@end


@implementation LSMyCartItemObject
- (id)init {
    if( self = [super init] ) {

    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorItem = [coder decodeObjectForKey:@"anchorItem"];
        self.giftList = [coder decodeObjectForKey:@"giftList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorItem forKey:@"anchorItem"];
    [coder encodeObject:self.giftList forKey:@"giftList"];
}

@end
