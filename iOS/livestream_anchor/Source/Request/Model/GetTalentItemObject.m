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
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.talentId = [coder decodeObjectForKey:@"talentId"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.credit = [coder decodeDoubleForKey:@"credit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.talentId forKey:@"talentId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeDouble:self.credit forKey:@"credit"];


}

@end
