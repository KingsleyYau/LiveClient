//
//  LSHangoutGiftListObject.m
//  dating
//
//  Created by Alex on 18/5/8.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSHangoutGiftListObject.h"
@interface LSHangoutGiftListObject () <NSCoding>
@end


@implementation LSHangoutGiftListObject

- (id)init {
    if( self = [super init] ) {
        self.buyforList = nil;
        self.normalList = nil;
        self.celebrationList = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.buyforList = [coder decodeObjectForKey:@"buyforList"];
        self.normalList = [coder decodeObjectForKey:@"normalList"];
        self.celebrationList = [coder decodeObjectForKey:@"celebrationList"];
       
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.buyforList forKey:@"buyforList"];
    [coder encodeObject:self.normalList forKey:@"normalList"];
    [coder encodeObject:self.celebrationList forKey:@"celebrationList"];

}

@end
