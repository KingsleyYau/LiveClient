//
//  LSTimeZoneItemObject.m
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSTimeZoneItemObject.h"
@interface LSTimeZoneItemObject () <NSCoding>
@end


@implementation LSTimeZoneItemObject
- (id)init {
    if( self = [super init] ) {
        self.zoneId = @"";
        self.value = @"";
        self.city = @"";
        self.cityCode = @"";
        self.summerTimeStart = 0;
        self.summerTimeEnd = 0;
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.zoneId = [coder decodeObjectForKey:@"zoneId"];
        self.value = [coder decodeObjectForKey:@"value"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.cityCode = [coder decodeObjectForKey:@"cityCode"];
        self.summerTimeStart = [coder decodeIntegerForKey:@"summerTimeStart"];
        self.summerTimeEnd = [coder decodeIntegerForKey:@"summerTimeEnd"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.zoneId forKey:@"zoneId"];
    [coder encodeObject:self.value forKey:@"value"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.cityCode forKey:@"cityCode"];
    [coder encodeInteger:self.summerTimeStart forKey:@"summerTimeStart"];
    [coder encodeInteger:self.summerTimeEnd forKey:@"summerTimeEnd"];
}

@end
