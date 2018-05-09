//
//  ZBViewerFansItemObject.m
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBViewerFansItemObject.h"
@interface ZBViewerFansItemObject () <NSCoding>
@end


@implementation ZBViewerFansItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.mountId = [coder decodeObjectForKey:@"mountId"];
        self.mountName = [coder decodeObjectForKey:@"mountName"];
        self.mountUrl = [coder decodeObjectForKey:@"mountUrl"];
        self.level = [coder decodeIntForKey:@"level"];
        self.isHasTicket = [coder decodeBoolForKey:@"isHasTicket"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.mountId forKey:@"mountId"];
    [coder encodeObject:self.mountName forKey:@"mountName"];
    [coder encodeObject:self.mountUrl forKey:@"mountUrl"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeBool:self.isHasTicket forKey:@"isHasTicket"];
}

@end
