//
//  LSSayHiTextItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiTextItemObject.h"
@interface LSSayHiTextItemObject () <NSCoding>
@end


@implementation LSSayHiTextItemObject

- (id)init {
    if( self = [super init] ) {
        self.textId = @"";
        self.text = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.textId = [coder decodeObjectForKey:@"textId"];
        self.text = [coder decodeObjectForKey:@"text"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.textId forKey:@"textId"];
    [coder encodeObject:self.text forKey:@"text"];

}

@end
