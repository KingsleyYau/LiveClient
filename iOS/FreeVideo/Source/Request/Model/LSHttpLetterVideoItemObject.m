//
//  LSHttpLetterVideoItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHttpLetterVideoItemObject.h"
@interface LSHttpLetterVideoItemObject () <NSCoding>
@end


@implementation LSHttpLetterVideoItemObject
- (id)init {
    if( self = [super init] ) {
        self.resourceId = @"";
        self.isFee = NO;
        self.status = LSPAYFEESTATUS_PAID;
        self.describe = @"";
        self.coverSmallImg = @"";
        self.coverOriginImg = @"";
        self.video = @"";
        self.videoTotalTime = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.resourceId = [coder decodeObjectForKey:@"resourceId"];
        self.isFee = [coder decodeBoolForKey:@"isFee"];
        self.status = [coder decodeIntForKey:@"status"];
        self.describe = [coder decodeObjectForKey:@"describe"];
        self.coverSmallImg = [coder decodeObjectForKey:@"coverSmallImg"];
        self.coverOriginImg = [coder decodeObjectForKey:@"coverOriginImg"];
        self.video = [coder decodeObjectForKey:@"video"];
        self.videoTotalTime = [coder decodeDoubleForKey:@"videoTotalTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.resourceId forKey:@"resourceId"];
    [coder encodeBool:self.isFee forKey:@"isFee"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.describe forKey:@"describe"];
    [coder encodeObject:self.coverSmallImg forKey:@"coverSmallImg"];
    [coder encodeObject:self.coverOriginImg forKey:@"coverOriginImg"];
    [coder encodeObject:self.video forKey:@"video"];
    [coder encodeDouble:self.videoTotalTime forKey:@"videoTotalTime"];
}

@end
