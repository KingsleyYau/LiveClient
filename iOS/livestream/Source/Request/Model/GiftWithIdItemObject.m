//
//  GiftWithIdItemObject.m
//  dating
//
//  Created by Alex on 17/8/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftWithIdItemObject.h"
@interface GiftWithIdItemObject () <NSCoding>
@end


@implementation GiftWithIdItemObject

- (id)init {
    if( self = [super init] ) {

        self.giftId = @"";
        self.isShow = NO;
        self.isPromo = NO;
        self.typeIdList = NULL;
        self.isFree = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.giftId = [coder decodeObjectForKey:@"giftId"];
        self.isShow = [coder decodeBoolForKey:@"isShow"];
        self.isPromo = [coder decodeBoolForKey:@"isPromo"];
        self.typeIdList = [coder decodeObjectForKey:@"typeIdList"];
        self.isFree = [coder decodeBoolForKey:@"isFree"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.giftId forKey:@"giftId"];
    [coder encodeBool:self.isShow forKey:@"isShow"];
    [coder encodeBool:self.isPromo forKey:@"isPromo"];
    [coder encodeObject:self.typeIdList forKey:@"typeIdList"];
    [coder encodeBool:self.isFree forKey:@"isFree"];
}

@end
