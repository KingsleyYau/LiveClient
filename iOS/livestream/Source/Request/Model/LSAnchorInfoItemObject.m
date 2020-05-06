//
//  LSAnchorInfoItemObject.m
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSAnchorInfoItemObject.h"
@interface LSAnchorInfoItemObject () <NSCoding>
@end


@implementation LSAnchorInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.address = @"";
        self.anchorType = ANCHORLEVELTYPE_UNKNOW;
        self.isLive = NO;
        self.introduction = @"";
        self.anchorPriv = NULL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.address = [coder decodeObjectForKey:@"address"];
        self.anchorType = [coder decodeIntForKey:@"anchorType"];
        self.isLive = [coder decodeBoolForKey:@"isLive"];
        self.introduction = [coder decodeObjectForKey:@"introduction"];
        self.anchorPriv = [coder decodeObjectForKey:@"anchorPriv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeInt:self.anchorType forKey:@"anchorType"];
    [coder encodeBool:self.isLive forKey:@"isLive"];
    [coder encodeObject:self.introduction forKey:@"introduction"];
    [coder encodeObject:self.anchorPriv forKey:@"anchorPriv"];
}

@end
