//
//  LSBindAnchorItemObject.m
//  dating
//
//  Created by Alex on 18/1/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSBindAnchorItemObject.h"
@interface LSBindAnchorItemObject () <NSCoding>
@end


@implementation LSBindAnchorItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.useRoomType = USEROOMTYPE_LIMITLESS;
        self.expTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.useRoomType = [coder decodeIntForKey:@"useRoomType"];
        self.expTime = [coder decodeIntegerForKey:@"expTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeInt:self.useRoomType forKey:@"useRoomType"];
    [coder encodeInteger:self.expTime forKey:@"expTime"];
}

@end
