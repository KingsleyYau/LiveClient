//
//  EmoticonInfoItemObject.m
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "EmoticonInfoItemObject.h"
@interface EmoticonInfoItemObject () <NSCoding>
@end


@implementation EmoticonInfoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.emoId = [coder decodeObjectForKey:@"emoId"];
        self.emoSign = [coder decodeObjectForKey:@"emoSign"];
        self.emoUrl = [coder decodeObjectForKey:@"emoUrl"];
        self.emoType = [coder decodeIntForKey:@"emoType"];
        self.emoIconUrl = [coder decodeObjectForKey:@"emoIconUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.emoId forKey:@"emoId"];
    [coder encodeObject:self.emoSign  forKey:@"emoSign"];
    [coder encodeObject:self.emoUrl forKey:@"emoUrl"];
    [coder encodeInt:self.emoType forKey:@"emoType"];
    [coder encodeObject:self.emoIconUrl forKey:@"emoIconUrl"];
}

@end
