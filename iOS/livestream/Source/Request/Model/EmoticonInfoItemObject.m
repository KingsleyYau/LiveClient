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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.emoId forKey:@"emoId"];
    [coder encodeObject:self.emoSign  forKey:@"emoSign"];
    [coder encodeObject:self.emoUrl forKey:@"emoUrl"];
}

@end
