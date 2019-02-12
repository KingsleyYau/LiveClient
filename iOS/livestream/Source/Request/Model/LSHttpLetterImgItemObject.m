//
//  LSHttpLetterImgItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHttpLetterImgItemObject.h"
@interface LSHttpLetterImgItemObject () <NSCoding>
@end


@implementation LSHttpLetterImgItemObject
- (id)init {
    if( self = [super init] ) {
        self.resourceId = @"";
        self.isFee = NO;
        self.status = LSPAYFEESTATUS_PAID;
        self.describe = @"";
        self.originImg = @"";
        self.smallImg = @"";
        self.blurImg = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.resourceId = [coder decodeObjectForKey:@"resourceId"];
        self.isFee = [coder decodeBoolForKey:@"isFee"];
        self.status = [coder decodeIntForKey:@"status"];
        self.describe = [coder decodeObjectForKey:@"describe"];
        self.originImg = [coder decodeObjectForKey:@"originImg"];
        self.smallImg = [coder decodeObjectForKey:@"smallImg"];
        self.blurImg = [coder decodeObjectForKey:@"blurImg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.resourceId forKey:@"resourceId"];
    [coder encodeBool:self.isFee forKey:@"isFee"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.describe forKey:@"describe"];
    [coder encodeObject:self.originImg forKey:@"originImg"];
    [coder encodeObject:self.smallImg forKey:@"smallImg"];
    [coder encodeObject:self.blurImg forKey:@"blurImg"];
}

@end
