//
//  LSVersionItemObject.m
//  dating
//
//  Created by Alex on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSVersionItemObject.h"
@interface LSVersionItemObject () <NSCoding>
@end


@implementation LSVersionItemObject

- (id)init {
    if( self = [super init] ) {
        self.versionCode = 0;
        self.versionName = @"";
        self.versionDesc = @"";
        self.isForceUpdate = NO;
        self.url = @"";
        self.storeUrl = @"";
        self.pubTime = @"";
        self.checkTime = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.versionCode = [coder decodeIntForKey:@"versionCode"];
        self.versionName = [coder decodeObjectForKey:@"versionName"];
        self.versionDesc = [coder decodeObjectForKey:@"versionDesc"];
        self.isForceUpdate = [coder decodeBoolForKey:@"isForceUpdate"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.storeUrl = [coder decodeObjectForKey:@"storeUrl"];
        self.pubTime = [coder decodeObjectForKey:@"pubTime"];
        self.checkTime = [coder decodeIntegerForKey:@"checkTime"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.versionCode forKey:@"versionCode"];
    [coder encodeObject:self.versionName forKey:@"versionName"];
    [coder encodeObject:self.versionDesc forKey:@"versionDesc"];
    [coder encodeBool:self.isForceUpdate forKey:@"isForceUpdate"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.storeUrl forKey:@"storeUrl"];
    [coder encodeObject:self.pubTime forKey:@"pubTime"];
    [coder encodeInteger:self.checkTime forKey:@"checkTime"];
}

@end
