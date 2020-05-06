//
//  LSRecommendAnchorItemObject.m
//  dating
//
//  Created by Alex on 19/6/11.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSRecommendAnchorItemObject.h"
@interface LSRecommendAnchorItemObject () <NSCoding>
@end


@implementation LSRecommendAnchorItemObject
- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorNickName = @"";
        self.anchorAge = 0;
        self.anchorCover = @"";
        self.anchorAvatar = @"";
        self.isFollow = NO;
        self.onlineStatus = ONLINE_STATUS_OFFLINE;
        self.publicRoomId = @"";
        self.roomType = HTTPROOMTYPE_NOLIVEROOM;
        self.lastCountactTime = 0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.anchorAge = [coder decodeIntForKey:@"anchorAge"];
        self.anchorCover = [coder decodeObjectForKey:@"anchorCover"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.isFollow = [coder decodeBoolForKey:@"isFollow"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.publicRoomId = [coder decodeObjectForKey:@"publicRoomId"];
        self.roomType = [coder decodeIntForKey:@"roomType"];
        self.priv = [coder decodeObjectForKey:@"priv"];
        self.lastCountactTime = [coder decodeIntegerForKey:@"lastCountactTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeInt:self.anchorAge forKey:@"anchorAge"];
    [coder encodeObject:self.anchorCover forKey:@"anchorCover"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeBool:self.isFollow forKey:@"isFollow"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeObject:self.publicRoomId forKey:@"publicRoomId"];
    [coder encodeInt:self.roomType forKey:@"roomType"];
    [coder encodeObject:self.priv forKey:@"priv"];
    [coder encodeInteger:self.lastCountactTime forKey:@"lastCountactTime"];

}

@end
