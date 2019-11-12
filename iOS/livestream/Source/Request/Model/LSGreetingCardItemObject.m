//
//  LSGreetingCardItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSGreetingCardItemObject.h"
@interface LSGreetingCardItemObject () <NSCoding>
@end


@implementation LSGreetingCardItemObject
- (id)init {
    if( self = [super init] ) {
        self.giftId = @"";
        self.giftName = @"";
        self.giftNumber = 0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftNumber = [coder decodeIntForKey:@"giftNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeInt:self.giftNumber forKey:@"giftNumber"];

}

@end
