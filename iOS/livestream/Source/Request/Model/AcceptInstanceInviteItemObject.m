//
//  AcceptInstanceInviteItemObject.m
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "AcceptInstanceInviteItemObject.h"
@interface AcceptInstanceInviteItemObject () <NSCoding>
@end


@implementation AcceptInstanceInviteItemObject

- (id)init {
    if( self = [super init] ) {
        self.roomId = @"";
        self.roomType = HTTPROOMTYPE_NOLIVEROOM;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
}

@end
