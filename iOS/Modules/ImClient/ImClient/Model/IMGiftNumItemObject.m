//
//  IMGiftNumItemObject.m
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IMGiftNumItemObject.h"

@implementation IMGiftNumItemObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];

}


@end
