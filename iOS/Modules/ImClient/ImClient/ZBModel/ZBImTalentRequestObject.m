//
//  ZBImTalentRequestObject.m
//  livestream
//
//  Created by Max on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ZBImTalentRequestObject.h"

@implementation ZBImTalentRequestObject

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.talentInviteId = [coder decodeObjectForKey:@"talentInviteId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.nickName = [coder decodeObjectForKey:@"nickName"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.talentInviteId forKey:@"talentInviteId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.nickName forKey:@"nickName"];


}


@end
