//
//  LSCheckoutItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSCheckoutItemObject.h"
@interface LSCheckoutItemObject () <NSCoding>
@end


@implementation LSCheckoutItemObject
- (id)init {
    if( self = [super init] ) {
        self.deliveryPrice = 0.0;
        self.holidayPrice = 0.0;
        self.totalPrice = 0.0;
        self.greetingmessage = @"";
        self.specialDeliveryRequest = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftList = [coder decodeObjectForKey:@"giftList"];
        self.greetingCard = [coder decodeObjectForKey:@"greetingCard"];
        self.deliveryPrice = [coder decodeDoubleForKey:@"deliveryPrice"];
        self.holidayPrice = [coder decodeDoubleForKey:@"holidayPrice"];
        self.totalPrice = [coder decodeDoubleForKey:@"totalPrice"];
        self.greetingmessage = [coder decodeObjectForKey:@"greetingmessage"];
        self.specialDeliveryRequest = [coder decodeObjectForKey:@"specialDeliveryRequest"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftList forKey:@"giftList"];
    [coder encodeObject:self.greetingCard forKey:@"greetingCard"];
    [coder encodeDouble:self.deliveryPrice forKey:@"deliveryPrice"];
    [coder encodeDouble:self.holidayPrice forKey:@"holidayPrice"];
    [coder encodeDouble:self.totalPrice forKey:@"totalPrice"];
    [coder encodeObject:self.greetingmessage forKey:@"greetingmessage"];
    [coder encodeObject:self.specialDeliveryRequest forKey:@"specialDeliveryRequest"];
}

@end
