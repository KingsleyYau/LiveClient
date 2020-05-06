//
//  LSScheduleAnchorInfoItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSScheduleAnchorInfoItemObject.h"
@interface LSScheduleAnchorInfoItemObject () <NSCoding>
@end


@implementation LSScheduleAnchorInfoItemObject
- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.nickName = @"";
        self.avatarImg = @"";
        self.onlineStatus = ONLINE_STATUS_OFFLINE;
        self.age = 0;
        self.country = @"";
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.avatarImg = [coder decodeObjectForKey:@"avatarImg"];
        self.onlineStatus = [coder decodeIntForKey:@"onlineStatus"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.avatarImg forKey:@"avatarImg"];
    [coder encodeInt:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];
}

@end
