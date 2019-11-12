//
//  LSFlowerGiftBaseInfoItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSFlowerGiftBaseInfoItemObject.h"
@interface LSFlowerGiftBaseInfoItemObject () <NSCoding>
@end


@implementation LSFlowerGiftBaseInfoItemObject
- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
        self.giftName = @"";
        self.giftImg = @"";
        self.giftNumber = 0;
        self.giftPrice = 0.0;
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeObject:self.giftImg forKey:@"giftImg"];
    [coder encodeInt:self.giftNumber forKey:@"giftNumber"];
    [coder encodeDouble:self.giftPrice forKey:@"giftPrice"];
}

@end
