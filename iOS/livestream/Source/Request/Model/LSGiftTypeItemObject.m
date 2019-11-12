//
//  LSGiftTypeItemObject.m
//  dating
//
//  Created by Alex on 19/8/27.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSGiftTypeItemObject.h"
@interface LSGiftTypeItemObject () <NSCoding>
@end


@implementation LSGiftTypeItemObject
- (id)init {
    if( self = [super init] ) {
        self.typeId = @"";
        self.typeName = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.typeId = [coder decodeObjectForKey:@"typeId"];
        self.typeName = [coder decodeObjectForKey:@"typeName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.typeId forKey:@"typeId"];
    [coder encodeObject:self.typeName forKey:@"typeName"];
}

@end
