//
//  LSGiftItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGiftItemObject.h"
@interface LSGiftItemObject () <NSCoding>
@end


@implementation LSGiftItemObject

- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.sendNumList = [coder decodeObjectForKey:@"sendNumList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.sendNumList forKey:@"sendNumList"];
}

@end
