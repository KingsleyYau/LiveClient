//
//  VoucherItemObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "VoucherItemObject.h"
@interface VoucherItemObject () <NSCoding>
@end


@implementation VoucherItemObject

- (id)init {
    if( self = [super init] ) {
        self.voucherId = @"";
        self.photoUrl = @"";
        self.photoUrlMobile = @"";
        self.desc = @"";
        self.useRoomType = 0;
        self.anchorType = 0;
        self.anchorId = @"";
        self.anchorNcikName = @"";
        self.anchorPhotoUrl = @"";
        self.grantedDate = 0;
        self.startValidDate = 0;
        self.expDate = 0;
        self.read = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.voucherId = [coder decodeObjectForKey:@"voucherId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.photoUrlMobile = [coder decodeObjectForKey:@"photoUrlMobile"];
        self.desc = [coder decodeObjectForKey:@"desc"];
        self.useRoomType = [coder decodeIntForKey:@"useRoomType"];
        self.anchorType = [coder decodeIntForKey:@"anchorType"];
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorNcikName = [coder decodeObjectForKey:@"anchorNcikName"];
        self.anchorPhotoUrl = [coder decodeObjectForKey:@"anchorPhotoUrl"];
        self.grantedDate = [coder decodeIntegerForKey:@"grantedDate"];
        self.startValidDate = [coder decodeIntegerForKey:@"startValidDate"];
        self.expDate = [coder decodeIntegerForKey:@"expDate"];
        self.read = [coder decodeBoolForKey:@"read"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.voucherId forKey:@"voucherId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.photoUrlMobile forKey:@"photoUrlMobile"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeInt:self.useRoomType forKey:@"useRoomType"];
    [coder encodeInt:self.anchorType forKey:@"anchorType"];
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorNcikName forKey:@"anchorNcikName"];
    [coder encodeObject:self.anchorPhotoUrl forKey:@"anchorPhotoUrl"];
    [coder encodeInteger:self.grantedDate forKey:@"grantedDate"];
    [coder encodeInteger:self.startValidDate forKey:@"startValidDate"];
    [coder encodeInteger:self.expDate forKey:@"expDate"];
    [coder encodeBool:self.read forKey:@"read"];
}

@end
