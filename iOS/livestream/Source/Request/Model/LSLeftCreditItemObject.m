//
//  LSLeftCreditItemObject.m
//  dating
//
//  Created by Alex on 19/6/20.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLeftCreditItemObject.h"
@interface LSLeftCreditItemObject () <NSCoding>
@end


@implementation LSLeftCreditItemObject
- (id)init {
    if( self = [super init] ) {
        self.credit = 0.0;
        self.coupon = 0;
        self.liveChatCount = 0;
        self.postStamp = 0.0;
        
    }
 return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.credit = [coder decodeDoubleForKey:@"credit"];
        self.coupon = [coder decodeIntForKey:@"coupon"];
        self.liveChatCount = [coder decodeIntForKey:@"liveChatCount"];
        self.postStamp = [coder decodeDoubleForKey:@"postStamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.credit forKey:@"credit"];
    [coder encodeInt:self.coupon forKey:@"coupon"];
    [coder encodeInt:self.liveChatCount forKey:@"liveChatCount"];
    [coder encodeDouble:self.postStamp forKey:@"postStamp"];
}

@end
