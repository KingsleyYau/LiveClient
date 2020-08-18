//
//  LSPremiumVideoinfoItemObject.m
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoinfoItemObject.h"
@interface LSPremiumVideoinfoItemObject () <NSCoding>
@end


@implementation LSPremiumVideoinfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.anchorId = @"";
        self.anchorAge = 0;
        self.anchorNickname = @"";
        self.anchorAvatarImg = @"";
        self.onlineStatus = NO;
        self.videoId = @"";
        self.title = @"";
        self.describe = @"";
        self.duration = 0;
        self.coverUrlPng = @"";
        self.coverUrlGif = @"";
        self.isInterested = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.anchorId = [coder decodeObjectForKey:@"anchorId"];
        self.anchorAge = [coder decodeIntForKey:@"anchorAge"];
        self.anchorNickname = [coder decodeObjectForKey:@"anchorNickname"];
        self.anchorAvatarImg = [coder decodeObjectForKey:@"anchorAvatarImg"];
        self.onlineStatus = [coder decodeBoolForKey:@"onlineStatus"];
        self.videoId = [coder decodeObjectForKey:@"videoId"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.describe = [coder decodeObjectForKey:@"describe"];
        self.duration = [coder decodeIntForKey:@"duration"];
        self.coverUrlPng = [coder decodeObjectForKey:@"coverUrlPng"];
        self.coverUrlGif = [coder decodeObjectForKey:@"coverUrlGif"];
        self.isInterested = [coder decodeBoolForKey:@"isInterested"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.anchorId forKey:@"anchorId"];
    [coder encodeInt:self.anchorAge forKey:@"anchorAge"];
    [coder encodeObject:self.anchorNickname forKey:@"anchorNickname"];
    [coder encodeObject:self.anchorAvatarImg forKey:@"anchorAvatarImg"];
    [coder encodeBool:self.onlineStatus forKey:@"onlineStatus"];
    [coder encodeObject:self.videoId forKey:@"videoId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.describe forKey:@"describe"];
    [coder encodeInt:self.duration forKey:@"duration"];
    [coder encodeObject:self.coverUrlPng forKey:@"coverUrlPng"];
    [coder encodeObject:self.coverUrlGif forKey:@"coverUrlGif"];
    [coder encodeBool:self.isInterested forKey:@"isInterested"];
}

#pragma mark - LSVideoItemCellViewModelProtocol
/**
 获取视频标题
 */
- (NSString *)getVideoItemModelTitle{
    return self.title;
}
/**
  获取视频描述内容
*/
- (NSString *)getVideoItemModelDetail{
    return self.describe;
}
/**
  获取视频的用户昵称
*/
- (NSString *)getVideoItemModelUsername{
    return self.anchorNickname;
}
/**
  获取视频的用户年龄
*/
- (NSString *)getVideoItemModelUserAge{
    return [NSString stringWithFormat:@"%d",self.anchorAge];
}
/**
  获取视频的时长
*/
- (NSString *)getVideoItemModelVideoTime{
    return [NSString stringWithFormat:@"%d",self.duration];
}
/**
  获取视频的用户头像
*/
- (NSString *)getVideoItemModelUserHeadImg{
    return self.anchorAvatarImg;
}
/**
  获取视频的封面图
*/
- (NSString *)getVideoItemModelCoverImg{
    return self.coverUrlPng;
}
/**
  是否收藏
*/
- (BOOL)getVideoItemModelIsFavorite{
    return self.isInterested;
}
/**
  是否在线
*/
- (BOOL)getVideoItemModelIsOnline{
    return self.onlineStatus;
}

@end
