//
//  ZBTodayCreditItemObject.m
//  dating
//
//  Created by Alex on 18/3/1.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "ZBTodayCreditItemObject.h"
@interface ZBTodayCreditItemObject () <NSCoding>
@end


@implementation ZBTodayCreditItemObject

- (id)init {
    if( self = [super init] ) {
        self.monthCredit = 0;
        self.monthCompleted = 0;
        self.monthTarget = 0;
        self.monthProgress = 0;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.monthCredit = [coder decodeIntForKey:@"monthCredit"];
        self.monthCompleted = [coder decodeIntForKey:@"monthCompleted"];
        self.monthTarget = [coder decodeIntForKey:@"monthTarget"];
        self.monthProgress = [coder decodeIntForKey:@"monthProgress"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.monthCredit forKey:@"monthCredit"];
   [coder encodeInt:self.monthCompleted forKey:@"monthCompleted"];
    [coder encodeInt:self.monthTarget forKey:@"monthTarget"];
    [coder encodeInt:self.monthProgress forKey:@"monthProgress"];

}

@end
