//
//  GiftInfoObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftInfoObject.h"
@interface GiftInfoObject () <NSCoding>
@end


@implementation GiftInfoObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.num = [coder decodeIntForKey:@"num"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInt:self.num forKey:@"num"];

}

@end
