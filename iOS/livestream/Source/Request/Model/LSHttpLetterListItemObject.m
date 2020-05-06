//
//  LSHttpLetterListItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHttpLetterListItemObject.h"
@interface LSHttpLetterListItemObject () <NSCoding>
@end


@implementation LSHttpLetterListItemObject
- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorAvatar= @"";
        self.anchorNickName= @"";
        self.isFollow = NO;
        self.onlineStatus = NO;
        self.letterId= @"";
        self.letterSendTime = 0;
        self.letterBrief= @"";
        self.hasImg = NO;
        self.hasVideo = NO;
        self.hasRead = NO;
        self.hasReplied = NO;
        self.hasSchedule = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.isFollow = [coder decodeBoolForKey:@"isFollow"];
        self.onlineStatus = [coder decodeBoolForKey:@"onlineStatus"];
        self.letterId = [coder decodeObjectForKey:@"letterId"];
        self.letterSendTime = [coder decodeIntegerForKey:@"letterSendTime"];
        self.letterBrief = [coder decodeObjectForKey:@"letterBrief"];
        self.hasImg = [coder decodeBoolForKey:@"hasImg"];
        self.hasVideo = [coder decodeBoolForKey:@"hasVideo"];
        self.hasRead = [coder decodeBoolForKey:@"hasRead"];
        self.hasReplied = [coder decodeBoolForKey:@"hasReplied"];
        self.hasSchedule = [coder decodeBoolForKey:@"hasSchedule"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeBool:self.isFollow forKey:@"isFollow"];
    [coder encodeBool:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeObject:self.letterId forKey:@"letterId"];
    [coder encodeInteger:self.letterSendTime forKey:@"letterSendTime"];
    [coder encodeObject:self.letterBrief forKey:@"letterBrief"];
    [coder encodeBool:self.hasImg forKey:@"hasImg"];
    [coder encodeBool:self.hasVideo forKey:@"hasVideo"];
    [coder encodeBool:self.hasRead forKey:@"hasRead"];
    [coder encodeBool:self.hasReplied forKey:@"hasReplied"];
    [coder encodeBool:self.hasSchedule forKey:@"hasSchedule"];
}

@end
