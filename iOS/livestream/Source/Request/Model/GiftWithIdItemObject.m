//
//  GiftWithIdItemObject.m
//  dating
//
//  Created by Alex on 17/8/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftWithIdItemObject.h"
@interface GiftWithIdItemObject () <NSCoding>
@end


@implementation GiftWithIdItemObject

- (id)init {
    if( self = [super init] ) {

        self.giftId = @"";
        self.isShow = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.isShow = [coder decodeBoolForKey:@"isShow"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeBool:self.isShow forKey:@"isShow"];
}

@end
