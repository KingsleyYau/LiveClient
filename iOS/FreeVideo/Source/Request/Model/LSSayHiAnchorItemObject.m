//
//  LSSayHiAnchorItemObject.m
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSayHiAnchorItemObject.h"
@interface LSSayHiAnchorItemObject () <NSCoding>
@end


@implementation LSSayHiAnchorItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.nickName = @"";
        self.coverImg = @"";
        self.onlineStatus = ONLINE_STATUS_LIVE;
        self.roomType = HTTPROOMTYPE_NOLIVEROOM;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.coverImg = [coder decodeObjectForKey:@"coverImg"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.coverImg forKey:@"coverImg"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeInt:self.roomType forKey:@"roomType"];

}

@end
