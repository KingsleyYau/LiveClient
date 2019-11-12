//
//  LSCheckoutGiftItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSCheckoutGiftItemObject.h"
@interface LSCheckoutGiftItemObject () <NSCoding>
@end


@implementation LSCheckoutGiftItemObject
- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
        self.giftName = @"";
        self.giftImg = @"";
        self.giftNumber = 0;
        self.giftPrice = 0.0;
        self.giftstatus = NO;
        self.isGreetingCard = NO;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftImg = [coder decodeObjectForKey:@"giftImg"];
        self.giftNumber = [coder decodeIntForKey:@"giftNumber"];
        self.giftPrice = [coder decodeDoubleForKey:@"giftPrice"];
        self.giftstatus = [coder decodeBoolForKey:@"giftstatus"];
        self.isGreetingCard = [coder decodeBoolForKey:@"isGreetingCard"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeObject:self.giftImg forKey:@"giftImg"];
    [coder encodeInt:self.giftNumber forKey:@"giftNumber"];
    [coder encodeDouble:self.giftPrice forKey:@"giftPrice"];
    [coder encodeBool:self.giftstatus forKey:@"giftstatus"];
    [coder encodeBool:self.isGreetingCard forKey:@"isGreetingCard"];
}

@end
