//
//  LSPremiumVideoDetailItemObject.m
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoDetailItemObject.h"
@interface LSPremiumVideoDetailItemObject () <NSCoding>
@end


@implementation LSPremiumVideoDetailItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.videoId = @"";
        self.typeList = NULL;
        self.title = @"";
        self.describe = @"";
        self.duration = 0;
        self.coverUrlPng = @"";
        self.coverUrlGif = @"";
        self.videoUrlShort = @"";
        self.videoUrlFull = @"";
        self.isInterested = NO;
        self.lockStatus = LSLOCKSTATUS_LOCK_NOREQUEST;
        self.requestId = @"";
        self.requestLastTime = 0;
        self.emfId = @"";
        self.unlockTime = 0;
        self.currentTime = 0;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.videoId = [coder decodeObjectForKey:@"videoId"];
        self.typeList = [coder decodeObjectForKey:@"typeList"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.describe = [coder decodeObjectForKey:@"describe"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.coverUrlPng = [coder decodeObjectForKey:@"coverUrlPng"];
        self.coverUrlGif = [coder decodeObjectForKey:@"coverUrlGif"];
        self.videoUrlShort = [coder decodeObjectForKey:@"videoUrlShort"];
        self.videoUrlFull = [coder decodeObjectForKey:@"videoUrlFull"];
        self.isInterested = [coder decodeBoolForKey:@"isInterested"];
        self.lockStatus = [coder decodeIntForKey:@"lockStatus"];
        self.requestId = [coder decodeObjectForKey:@"requestId"];
        self.requestLastTime = [coder decodeIntegerForKey:@"requestLastTime"];
        self.emfId = [coder decodeObjectForKey:@"emfId"];
        self.unlockTime = [coder decodeIntegerForKey:@"unlockTime"];
        self.currentTime = [coder decodeIntegerForKey:@"currentTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.videoId forKey:@"videoId"];
    [coder encodeObject:self.typeList forKey:@"typeList"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.description forKey:@"description"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeObject:self.coverUrlPng forKey:@"coverUrlPng"];
    [coder encodeObject:self.coverUrlGif forKey:@"coverUrlGif"];
    [coder encodeObject:self.videoUrlShort forKey:@"videoUrlShort"];
    [coder encodeObject:self.videoUrlFull forKey:@"videoUrlFull"];
    [coder encodeBool:self.isInterested forKey:@"isInterested"];
    [coder encodeInt:self.lockStatus forKey:@"lockStatus"];
    [coder encodeObject:self.requestId forKey:@"requestId"];
    [coder encodeInteger:self.requestLastTime forKey:@"requestLastTime"];
    [coder encodeObject:self.emfId forKey:@"emfId"];
    [coder encodeInteger:self.unlockTime forKey:@"unlockTime"];
    [coder encodeInteger:self.currentTime forKey:@"currentTime"];
}

@end
