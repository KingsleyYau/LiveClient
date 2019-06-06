//
//  LSSayHiResourceConfigItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSayHiResourceConfigItemObject.h"
@interface LSSayHiResourceConfigItemObject () <NSCoding>
@end


@implementation LSSayHiResourceConfigItemObject

- (id)init {
    if( self = [super init] ) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.themeList = [coder decodeObjectForKey:@"themeList"];
        self.textList = [coder decodeObjectForKey:@"textList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.themeList forKey:@"themeList"];
    [coder encodeObject:self.textList forKey:@"textList"];
}

@end
