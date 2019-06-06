//
//  CoverPhotoItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "CoverPhotoItemObject.h"
@interface CoverPhotoItemObject () <NSCoding>
@end


@implementation CoverPhotoItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.photoId = [coder decodeObjectForKey:@"photoId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.status = (ExamineStatus) [coder decodeIntForKey:@"status"];
        self.in_use = [coder decodeBoolForKey:@"in_use"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.photoId  forKey:@"photoId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeBool:self.in_use forKey:@"in_use"];
}

@end
