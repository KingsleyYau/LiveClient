//
//  ImTalentReplyObject.m
//  dating
//
//  Created by Alex on 17/09/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ImTalentReplyObject.h"
@interface ImTalentReplyObject () <NSCoding>
@end


@implementation ImTalentReplyObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.roomId = [coder decodeObjectForKey:@"roomId"];
        self.talentInviteId = [coder decodeObjectForKey:@"talentInviteId"];
        self.talentId = [coder decodeObjectForKey:@"talentId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.status = [coder decodeIntForKey:@"status"];
        self.rebateCredit = [coder decodeDoubleForKey:@"rebateCredit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.roomId forKey:@"roomId"];
    [coder encodeObject:self.talentInviteId forKey:@"talentInviteId"];
    [coder encodeObject:self.talentId forKey:@"talentId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeDouble:self.rebateCredit forKey:@"rebateCredit"];

}

@end
