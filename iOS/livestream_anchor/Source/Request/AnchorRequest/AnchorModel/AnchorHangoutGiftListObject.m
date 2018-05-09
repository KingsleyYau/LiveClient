//
//  AnchorHangoutGiftListObject.m
//  dating
//
//  Created by Alex on 18/4/4.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "AnchorHangoutGiftListObject.h"
@interface AnchorHangoutGiftListObject () <NSCoding>
@end


@implementation AnchorHangoutGiftListObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.buyforList = [coder decodeObjectForKey:@"buyforList"];
        self.normalList = [coder decodeObjectForKey:@"normalList"];
        self.celebrationList = [coder decodeObjectForKey:@"celebrationList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.buyforList forKey:@"buyforList"];
    [coder encodeObject:self.normalList forKey:@"normalList"];
    [coder encodeObject:self.celebrationList forKey:@"celebrationList"];
}

@end
