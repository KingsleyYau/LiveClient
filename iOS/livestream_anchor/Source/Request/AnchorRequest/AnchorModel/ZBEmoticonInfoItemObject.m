//
//  ZBEmoticonInfoItemObject.m
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBEmoticonInfoItemObject.h"
@interface ZBEmoticonInfoItemObject () <NSCoding>
@end


@implementation ZBEmoticonInfoItemObject
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
