//
//  LSCheckDiscountItemObject.m
//  dating
//
//  Created by Alex on 19/11/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSCheckDiscountItemObject.h"
@interface LSCheckDiscountItemObject () <NSCoding>
@end


@implementation LSCheckDiscountItemObject
- (id)init {
    if( self = [super init] ) {
        self.type = LSDISCOUNTTYPE_UNKNOW;
        self.name = @"";
        self.discount = 0.0;
        self.imgUrl = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.type = [coder decodeIntForKey:@"type"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.discount = [coder decodeDoubleForKey:@"discount"];
        self.imgUrl = [coder decodeObjectForKey:@"imgUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeDouble:self.discount forKey:@"discount"];
    [coder encodeObject:self.imgUrl forKey:@"imgUrl"];
}

@end
