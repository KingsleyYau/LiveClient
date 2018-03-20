//
//  ZBLSLoginItemObject.m
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBLSLoginItemObject.h"
@interface ZBLSLoginItemObject () <NSCoding>
@end


@implementation ZBLSLoginItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.token forKey:@"email"];
    [coder encodeObject:self.nickName forKey:@"nickName"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
}

@end
