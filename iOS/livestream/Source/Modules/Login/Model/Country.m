//
//  Country.m

//  Created by lance on 16/6/15.
//  Copyright © 2016年  All rights reserved.
//

#import "Country.h"
#import "LiveBundle.h"

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

+ (Country *)findByShortName:(NSString *)shortName {
 
    NSString *profilePlistPath = [[LiveBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
    NSArray *profileArray = [[NSArray alloc] initWithContentsOfFile:profilePlistPath];
    
    for (NSDictionary *dict in profileArray) {
        Country  *country = [[Country alloc] initWithDict:dict];
        if ([country.shortName isEqualToString:shortName]) {
            if ([country.shortName isEqualToString:@"AU"]||[country.shortName isEqualToString:@"US"]) {
                return country;
            }
            return country;
        }
    }
    return nil;
}

+ (Country *)findPhoneCodeByCountry {
    NSLocale *local = [NSLocale currentLocale];
    NSString *countryCode = [local objectForKey:NSLocaleCountryCode];
    // 根据国籍区号获得手机区号
    Country *country = [Country findByShortName:countryCode];
    return country;
}
@end
