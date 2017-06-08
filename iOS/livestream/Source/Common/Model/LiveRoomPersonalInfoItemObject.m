//
//  LiveRoomPersonalInfoItemObject.m
//  dating
//
//  Created by Alex on 17/5/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LiveRoomPersonalInfoItemObject.h"
@interface LiveRoomPersonalInfoItemObject () <NSCoding>
@end


@implementation LiveRoomPersonalInfoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.gender = (Gender)[coder decodeIntForKey:@"gender"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeInt:self.gender forKey:@"gender"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
}

@end
