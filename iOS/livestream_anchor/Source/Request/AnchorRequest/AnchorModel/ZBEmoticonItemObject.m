//
//  ZBEmoticonItemObject.m
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBEmoticonItemObject.h"
@interface ZBEmoticonItemObject () <NSCoding>
@end


@implementation ZBEmoticonItemObject

- (id)init {
    if( self = [super init] ) {
        self.type = ZBEMOTICONTYPE_STANDARD;
        self.name = @"";
        self.errMsg = @"";
        self.emoUrl = @"";
        self.emoList = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.type = [coder decodeIntForKey:@"type"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.errMsg = [coder decodeObjectForKey:@"errMsg"];
        self.emoUrl = [coder decodeObjectForKey:@"emoUrl"];
        self.emoList = [coder decodeObjectForKey:@"emoList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.errMsg forKey:@"errMsg"];
    [coder encodeObject:self.emoUrl forKey:@"emoUrl"];
    [coder encodeObject:self.emoList forKey:@"emoList"];
}

@end
