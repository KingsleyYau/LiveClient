//
//  BookPhoneItemObject.m
//  dating
//
//  Created by Alex on 17/9/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BookPhoneItemObject.h"
@interface BookPhoneItemObject () <NSCoding>
@end


@implementation BookPhoneItemObject

- (id)init {
    if( self = [super init] ) {
        self.country = @"";
        self.areaCode = @"";
        self.phoneNo = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.country = [coder decodeObjectForKey:@"country"];
        self.areaCode = [coder decodeObjectForKey:@"areaCode"];
        self.phoneNo = [coder decodeObjectForKey:@"phoneNo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.country forKey:@"country"];
    [coder encodeObject:self.areaCode forKey:@"areaCode"];
    [coder encodeObject:self.phoneNo forKey:@"phoneNo"];
}

@end
