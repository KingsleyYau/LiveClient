//
//  LSDeliveryItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSDeliveryItemObject.h"
@interface LSDeliveryItemObject () <NSCoding>
@end


@implementation LSDeliveryItemObject
- (id)init {
    if( self = [super init] ) {
        self.orderNumber = @"";
        self.orderDate = 0;
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.anchorAvatar = @"";
        self.deliveryStatus = LSDELIVERYSTATUS_UNKNOW;
        self.deliveryStatusVal = @"";
        self.greetingMessage = @"";
        self.specialDeliveryRequest = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.orderNumber = [coder decodeObjectForKey:@"orderNumber"];
        self.orderDate = [coder decodeIntegerForKey:@"orderDate"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.deliveryStatus = [coder decodeIntForKey:@"deliveryStatus"];
        self.deliveryStatusVal = [coder decodeObjectForKey:@"deliveryStatusVal"];
        self.giftList = [coder decodeObjectForKey:@"giftList"];
        self.greetingMessage = [coder decodeObjectForKey:@"greetingMessage"];
        self.specialDeliveryRequest = [coder decodeObjectForKey:@"specialDeliveryRequest"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.orderNumber forKey:@"orderNumber"];
    [coder encodeInteger:self.orderDate forKey:@"orderDate"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeInt:self.deliveryStatus forKey:@"deliveryStatus"];
    [coder encodeObject:self.deliveryStatusVal forKey:@"deliveryStatusVal"];
    [coder encodeObject:self.giftList forKey:@"giftList"];
    [coder encodeObject:self.greetingMessage forKey:@"greetingMessage"];
    [coder encodeObject:self.specialDeliveryRequest forKey:@"specialDeliveryRequest"];
}

@end
