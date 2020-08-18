//
//  LSMailPriceItemObject.m
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSMailPriceItemObject.h"
@interface LSMailPriceItemObject () <NSCoding>
@end


@implementation LSMailPriceItemObject

- (id)init {
    if( self = [super init] ) {
        self.creditPrice = 0.0;
        self.stampPrice = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.creditPrice = [coder decodeDoubleForKey:@"creditPrice"];
        self.stampPrice = [coder decodeDoubleForKey:@"stampPrice"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.creditPrice forKey:@"creditPrice"];
    [coder encodeDouble:self.stampPrice forKey:@"stampPrice"];

}

@end
