//
//  LSScheduleDurationItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSScheduleDurationItemObject.h"
@interface LSScheduleDurationItemObject () <NSCoding>
@end


@implementation LSScheduleDurationItemObject
- (id)init {
    if( self = [super init] ) {
        self.duration = 0;
        self.isDefault = NO;
        self.credit = 0.0;
        self.originalCredit = 0.0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.duration = [coder decodeIntForKey:@"duration"];
        self.isDefault = [coder decodeBoolForKey:@"isDefault"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.originalCredit = [coder decodeDoubleForKey:@"originalCredit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeBool:self.isDefault forKey:@"isDefault"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeDouble:self.originalCredit forKey:@"originalCredit"];
}

@end
