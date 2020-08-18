//
//  LSPremiumVideoinfoItemObject
//  dating
//
//  Created by Alex on 20/08/03.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSVideoItemCellViewModelProtocol.h"
@interface LSPremiumVideoinfoItemObject : NSObject<LSVideoItemCellViewModelProtocol>
/**
 * 付费视频基本信息结构体
 * anchorId                     主播ID
 * anchorAge                 主播年龄
 * anchorNickname       主播昵称
 * anchorAvatarImg       主播头像
 * onlineStatus             是否在线
 * videoId                      视频ID
 * title                            视频标题
 * description                视频描述
 * duration                     视频时长(单位:秒)
 * coverUrlPng              视频png封面地址
 * coverUrlGif               视频gif封面地址
 * isInterested             是否感兴趣
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, assign) int anchorAge;
@property (nonatomic, copy) NSString* anchorNickname;
@property (nonatomic, copy) NSString* anchorAvatarImg;
@property (nonatomic, assign) BOOL onlineStatus;
@property (nonatomic, copy) NSString* videoId;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* describe;
@property (nonatomic, assign) int duration;
@property (nonatomic, copy) NSString* coverUrlPng;
@property (nonatomic, copy) NSString* coverUrlGif;
@property (nonatomic, assign) BOOL isInterested;

@end
