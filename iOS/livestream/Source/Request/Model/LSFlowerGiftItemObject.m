//
//  LSFlowerGiftItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSFlowerGiftItemObject.h"
@interface LSFlowerGiftItemObject () <NSCoding>
@end


@implementation LSFlowerGiftItemObject
- (id)init {
    if( self = [super init] ) {
        self.typeId = @"";
        self.giftId = @"";
        self.giftName = @"";
        self.giftImg = @"";
        self.priceShowType = LSPRICESHOWTYPE_WEEKDAY;
        self.giftWeekdayPrice = 0.0;
        self.giftDiscountPrice = 0.0;
        self.giftPrice = 0.0;
        self.giftDiscount = 0.0;
        self.isNew = NO;
        self.giftDescription = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.typeId = [coder decodeObjectForKey:@"typeId"];
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftImg = [coder decodeObjectForKey:@"giftImg"];
        self.priceShowType = [coder decodeIntForKey:@"priceShowType"];
        self.giftWeekdayPrice = [coder decodeDoubleForKey:@"giftWeekdayPrice"];
        self.giftDiscountPrice = [coder decodeDoubleForKey:@"giftDiscountPrice"];
        self.giftPrice = [coder decodeDoubleForKey:@"giftPrice"];
        self.giftDiscount = [coder decodeDoubleForKey:@"giftDiscount"];
        self.isNew = [coder decodeBoolForKey:@"isNew"];
        self.deliverableCountry = [coder decodeObjectForKey:@"deliverableCountry"];
        self.giftDescription = [coder decodeObjectForKey:@"giftDescription"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.typeId forKey:@"typeId"];
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeObject:self.giftImg forKey:@"giftImg"];
    [coder encodeInt:self.priceShowType forKey:@"priceShowType"];
    [coder encodeDouble:self.giftWeekdayPrice forKey:@"giftWeekdayPrice"];
    [coder encodeDouble:self.giftDiscountPrice forKey:@"giftDiscountPrice"];
    [coder encodeDouble:self.giftPrice forKey:@"giftPrice"];
    [coder encodeDouble:self.giftDiscount forKey:@"giftDiscount"];
    [coder encodeBool:self.isNew forKey:@"isNew"];
    [coder encodeObject:self.deliverableCountry forKey:@"deliverableCountry"];
    [coder encodeObject:self.giftDescription forKey:@"giftDescription"];
}

@end
