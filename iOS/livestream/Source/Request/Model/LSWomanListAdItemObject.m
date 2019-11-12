//
//  LSWomanListAdItemObject.m
//  dating
//
//  Created by test on 2019/10/8.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSWomanListAdItemObject.h"

@implementation LSWomanListAdItemObject

- (id)init {
    if( self = [super init] ) {
        self.advertId = @"";
        self.image = @"";
        self.width = 0;
        self.height = 0;
        self.adurl = @"";
        self.openType = LSAD_OT_UNKNOW;
        self.advertTitle = @"";
        self.type = LSAD_SPACE_TYPE_UNKNOW;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.advertId = [coder decodeObjectForKey:@"advertId"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.width = [coder decodeIntForKey:@"width"];
        self.height = [coder decodeIntForKey:@"height"];
        self.adurl = [coder decodeObjectForKey:@"adurl"];
        self.openType = [coder decodeIntForKey:@"openType"];
        self.advertTitle = [coder decodeObjectForKey:@"advertTitle"];
        self.type = [coder decodeIntForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.advertId forKey:@"advertId"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeInt:self.width forKey:@"width"];
    [coder encodeInt:self.height forKey:@"height"];
    [coder encodeObject:self.adurl forKey:@"adurl"];
    [coder encodeInt:self.openType forKey:@"openType"];
    [coder encodeObject:self.advertTitle forKey:@"advertTitle"];
    [coder encodeInt:self.type forKey:@"type"];
}


@end
