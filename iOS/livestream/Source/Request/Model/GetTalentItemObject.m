//
//  GetTalentItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetTalentItemObject.h"
@interface GetTalentItemObject () <NSCoding>
@end


@implementation GetTalentItemObject

- (id)init {
    if( self = [super init] ) {
        self.talentId = @"";
        self.name = @"";
        self.credit = 0.0;
        self.decription = @"";
        self.giftId = @"";
        self.giftName = @"";
        self.giftNum = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.talentId = [coder decodeObjectForKey:@"talentId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.decription = [coder decodeObjectForKey:@"decription"];
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.giftName = [coder decodeObjectForKey:@"giftName"];
        self.giftNum = [coder decodeIntForKey:@"giftNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.talentId forKey:@"talentId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeObject:self.decription forKey:@"decription"];
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeObject:self.giftName forKey:@"giftName"];
    [coder encodeInt:self.giftNum forKey:@"giftNum"];

}

@end
