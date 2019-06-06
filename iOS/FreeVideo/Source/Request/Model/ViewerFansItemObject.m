//
//  ViewerFansItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ViewerFansItemObject.h"
@interface ViewerFansItemObject () <NSCoding>
@end


@implementation ViewerFansItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.mountId = [coder decodeObjectForKey:@"mountId"];
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
    [coder encodeObject:self.mountUrl forKey:@"mountUrl"];
    [coder encodeInt:self.level forKey:@"level"];
    [coder encodeBool:self.isHasTicket forKey:@"isHasTicket"];
}

@end
