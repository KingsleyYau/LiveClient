//
//  GiftItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftItemObject.h"
@interface GiftItemObject () <NSCoding>
@end


@implementation GiftItemObject

- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftNumList = [coder decodeObjectForKey:@"giftNumList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftNumList forKey:@"giftNumList"];
}

@end
