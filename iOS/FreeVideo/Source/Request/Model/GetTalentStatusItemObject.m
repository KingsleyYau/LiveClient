//
//  GetTalentStatusItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetTalentStatusItemObject.h"
@interface GetTalentStatusItemObject () <NSCoding>
@end


@implementation GetTalentStatusItemObject

- (id)init {
    if( self = [super init] ) {
        self.talentInviteId = @"";
        self.talentId = @"";
        self.name = @"";
        self.credit = 0.0;
        self.status = 0;
        self.giftId = @"";
        self.giftName = @"";
        self.giftNum = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.talentInviteId = [coder decodeObjectForKey:@"talentInviteId"];
        self.talentId = [coder decodeObjectForKey:@"talentId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.status = [coder decodeIntForKey:@"status"];
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.talentInviteId forKey:@"talentInviteId"];
    [coder encodeObject:self.talentId forKey:@"talentId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];

}

@end
