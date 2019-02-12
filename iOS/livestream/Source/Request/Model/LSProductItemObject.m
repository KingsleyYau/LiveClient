//
//  LSProductItemObject.m
//  dating
//
//  Created by Alex on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSProductItemObject.h"
@interface LSProductItemObject () <NSCoding>
@end


@implementation LSProductItemObject

- (id)init {
    if( self = [super init] ) {
        self.productId = @"";
        self.name = @"";
        self.price = @"";
        self.icon = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.productId = [coder decodeObjectForKey:@"productId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.price = [coder decodeObjectForKey:@"price"];
        self.icon = [coder decodeObjectForKey:@"icon"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.productId forKey:@"productId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.price forKey:@"price"];
    [coder encodeObject:self.icon forKey:@"icon"];
}

@end
