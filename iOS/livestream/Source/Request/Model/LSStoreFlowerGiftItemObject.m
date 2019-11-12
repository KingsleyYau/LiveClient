//
//  LSStoreFlowerGiftItemObject.m
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSStoreFlowerGiftItemObject.h"
@interface LSStoreFlowerGiftItemObject () <NSCoding>
@end


@implementation LSStoreFlowerGiftItemObject
- (id)init {
    if( self = [super init] ) {
        self.typeId = @"";
        self.typeName = @"";
        self.isHasGreeting = NO;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.typeId = [coder decodeObjectForKey:@"typeId"];
        self.typeName = [coder decodeObjectForKey:@"typeName"];
        self.isHasGreeting = [coder decodeBoolForKey:@"isHasGreeting"];
        self.giftList = [coder decodeObjectForKey:@"giftList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.typeId forKey:@"typeId"];
    [coder encodeObject:self.typeName forKey:@"typeName"];
    [coder encodeBool:self.isHasGreeting forKey:@"isHasGreeting"];
    [coder encodeObject:self.giftList forKey:@"giftList"];
}

@end
