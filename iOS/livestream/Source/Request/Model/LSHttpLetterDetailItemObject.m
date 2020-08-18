//
//  LSHttpLetterDetailItemObject.m
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSHttpLetterDetailItemObject.h"
@interface LSHttpLetterDetailItemObject () <NSCoding>
@end


@implementation LSHttpLetterDetailItemObject
- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorCover = @"";
        self.anchorAvatar= @"";
        self.anchorNickName= @"";
        self.age = 0;
        self.country= @"";
        self.onlineStatus = NO;
        self.isInPublic = NO;
        self.isFollow = NO;
        self.letterId= @"";
        self.letterSendTime = 0;
        self.letterContent= @"";
        self.hasRead = NO;
        self.hasReplied = NO;
        self.scheduleInfo = NULL;
        self.accessKeyInfo = NULL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorCover = [coder decodeObjectForKey:@"anchorCover"];
        self.anchorAvatar = [coder decodeObjectForKey:@"anchorAvatar"];
        self.anchorNickName = [coder decodeObjectForKey:@"anchorNickName"];
        self.age = [coder decodeIntForKey:@"age"];
        self.country = [coder decodeObjectForKey:@"country"];
        self.onlineStatus = [coder decodeBoolForKey:@"onlineStatus"];
        self.isInPublic = [coder decodeBoolForKey:@"isInPublic"];
        self.isFollow = [coder decodeBoolForKey:@"isFollow"];
        self.letterId = [coder decodeObjectForKey:@"letterId"];
        self.letterSendTime = [coder decodeIntegerForKey:@"letterSendTime"];
        self.letterContent = [coder decodeObjectForKey:@"letterContent"];
        self.hasRead = [coder decodeBoolForKey:@"hasRead"];
        self.hasReplied = [coder decodeBoolForKey:@"hasReplied"];
        self.letterImgList = [coder decodeObjectForKey:@"letterImgList"];
        self.letterVideoList = [coder decodeObjectForKey:@"letterVideoList"];
        self.scheduleInfo = [coder decodeObjectForKey:@"scheduleInfo"];
        self.accessKeyInfo = [coder decodeObjectForKey:@"accessKeyInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeObject:self.anchorCover forKey:@"anchorCover"];
    [coder encodeObject:self.anchorAvatar forKey:@"anchorAvatar"];
    [coder encodeObject:self.anchorNickName forKey:@"anchorNickName"];
    [coder encodeInt:self.age forKey:@"age"];
    [coder encodeObject:self.country forKey:@"country"];
    [coder encodeBool:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeBool:self.isInPublic forKey:@"isInPublic"];
    [coder encodeBool:self.isFollow forKey:@"isFollow"];
    [coder encodeObject:self.letterId forKey:@"letterId"];
    [coder encodeInteger:self.letterSendTime forKey:@"letterSendTime"];
    [coder encodeObject:self.letterContent forKey:@"letterContent"];
    [coder encodeBool:self.hasRead forKey:@"hasRead"];
    [coder encodeBool:self.hasReplied forKey:@"hasReplied"];
    [coder encodeObject:self.letterImgList forKey:@"letterImgList"];
    [coder encodeObject:self.letterVideoList forKey:@"letterVideoList"];
    [coder encodeObject:self.scheduleInfo forKey:@"scheduleInfo"];
    [coder encodeObject:self.accessKeyInfo forKey:@"accessKeyInfo"];
}

@end
