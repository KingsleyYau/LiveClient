//
//  LSPremiumVideoTypeItemObject.m
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoTypeItemObject.h"
@interface LSPremiumVideoTypeItemObject () <NSCoding>
@end


@implementation LSPremiumVideoTypeItemObject

- (id)init {
    if( self = [super init] ) {
        self.typeId = @"";
        self.typeName = @"";
        self.isDefault = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.typeId = [coder decodeObjectForKey:@"typeId"];
        self.typeName = [coder decodeObjectForKey:@"typeName"];
        self.isDefault = [coder decodeBoolForKey:@"isDefault"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.typeId forKey:@"typeId"];
    [coder encodeObject:self.typeName forKey:@"typeName"];
    [coder encodeBool:self.isDefault forKey:@"isDefault"];
}

@end
