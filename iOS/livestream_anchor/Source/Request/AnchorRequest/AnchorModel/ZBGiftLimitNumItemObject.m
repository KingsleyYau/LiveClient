//
//  ZBGiftLimitNumItemObject.m
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBGiftLimitNumItemObject.h"
@interface ZBGiftLimitNumItemObject () <NSCoding>
@end


@implementation ZBGiftLimitNumItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId  forKey:@"giftId"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];
}

@end
