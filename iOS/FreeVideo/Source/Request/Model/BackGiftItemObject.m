//
//  BackGiftItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BackGiftItemObject.h"
@interface BackGiftItemObject () <NSCoding>
@end


@implementation BackGiftItemObject

- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
        self.num = 0;
        self.grantedDate = 0;
        self.startValidDate = 0;
        self.expDate = 0;
        self.read = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.num = [coder decodeIntForKey:@"num"];
        self.grantedDate = [coder decodeIntegerForKey:@"grantedDate"];
        self.startValidDate = [coder decodeIntegerForKey:@"startValidDate"];
        self.expDate = [coder decodeIntegerForKey:@"expDate"];
        self.read = [coder decodeBoolForKey:@"read"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeInt:self.num forKey:@"num"];
    [coder encodeInteger:self.grantedDate forKey:@"grantedDate"];
    [coder encodeInteger:self.startValidDate forKey:@"startValidDate"];
    [coder encodeInteger:self.expDate forKey:@"expDate"];
    [coder encodeBool:self.read forKey:@"read"];
}

@end
