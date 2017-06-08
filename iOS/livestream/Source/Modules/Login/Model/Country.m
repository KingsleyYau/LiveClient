//
//  Country.m

//  Created by lance on 16/6/15.
//  Copyright © 2016年  All rights reserved.
//

#import "Country.h"


@interface Country ()


@end

@implementation Country

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.fullName = dict[@"fullName"];
        self.zipCode = dict[@"zipCode"];
        self.shortName = dict[@"shortName"];
        NSString *firstLetter = self.fullName;
        self.firstLetter = [[firstLetter uppercaseString] substringToIndex:1];
    }
    return self;
}


@end
