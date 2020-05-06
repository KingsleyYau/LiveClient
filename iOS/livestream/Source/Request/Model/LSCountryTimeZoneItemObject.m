//
//  LSCountryTimeZoneItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSCountryTimeZoneItemObject.h"
@interface LSCountryTimeZoneItemObject () <NSCoding>
@end


@implementation LSCountryTimeZoneItemObject
- (id)init {
    if( self = [super init] ) {
        self.countryCode = @"";
        self.countryName = @"";
        self.isDefault = NO;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.countryCode = [coder decodeObjectForKey:@"countryCode"];
        self.countryName = [coder decodeObjectForKey:@"countryName"];
        self.isDefault = [coder decodeBoolForKey:@"isDefault"];
        self.timeZoneList = [coder decodeObjectForKey:@"timeZoneList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.countryCode forKey:@"countryCode"];
    [coder encodeObject:self.countryName forKey:@"countryName"];
    [coder encodeBool:self.isDefault forKey:@"isDefault"];
    [coder encodeObject:self.timeZoneList forKey:@"timeZoneList"];
}

@end
