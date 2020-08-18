//
//  LSAccessKeyinfoItemObject.m
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSAccessKeyinfoItemObject.h"
@interface LSAccessKeyinfoItemObject () <NSCoding>
@end


@implementation LSAccessKeyinfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.videoId = @"";
        self.title = @"";
        self.describe = @"";
        self.duration = 0;
        self.coverUrlPng = @"";
        self.coverUrlGif = @"";
        self.accessKey = @"";
        self.accessKeyStatus = LSACCESSKEYSTATUS_NOUSE;
        self.validTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.videoId = [coder decodeObjectForKey:@"videoId"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.describe = [coder decodeObjectForKey:@"describe"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.coverUrlPng = [coder decodeObjectForKey:@"coverUrlPng"];
        self.coverUrlGif = [coder decodeObjectForKey:@"coverUrlGif"];
        self.accessKey = [coder decodeObjectForKey:@"accessKey"];
        self.accessKeyStatus = [coder decodeIntForKey:@"accessKeyStatus"];
        self.validTime = [coder decodeIntegerForKey:@"validTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.videoId forKey:@"videoId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.describe forKey:@"describe"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeObject:self.coverUrlPng forKey:@"coverUrlPng"];
    [coder encodeObject:self.coverUrlGif forKey:@"coverUrlGif"];
    [coder encodeObject:self.accessKey forKey:@"accessKey"];
    [coder encodeInt:self.accessKeyStatus forKey:@"accessKeyStatus"];
    [coder encodeInteger:self.validTime forKey:@"validTime"];
}


@end
