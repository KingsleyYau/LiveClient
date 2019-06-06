//
//  LSHangoutStatusItemObject.m
//  dating
//
//  Created by Alex on 19/1/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHangoutStatusItemObject.h"
@interface LSHangoutStatusItemObject () <NSCoding>
@end


@implementation LSHangoutStatusItemObject

- (id)init {
    if( self = [super init] ) {
        self.liveRoomId = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.liveRoomId = [coder decodeObjectForKey:@"liveRoomId"];
        self.anchorList = [coder decodeObjectForKey:@"anchorList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.liveRoomId forKey:@"liveRoomId"];
    [coder encodeObject:self.anchorList forKey:@"anchorList"];
}

@end
