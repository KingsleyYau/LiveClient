//
//  LSHttpLetterDetailItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSHttpLetterImgItemObject.h"
#import "LSHttpLetterVideoItemObject.h"
#import "LSScheduleInviteDetailItemObject.h"
#import "LSAccessKeyinfoItemObject.h"

@interface LSHttpLetterDetailItemObject : NSObject
{

}
/**
 * 信件详情
 * anchorId           主播ID
 * anchorCover        主播封面图URL
 * anchorAvatar       主播头像
 * anchorNickName     主播昵称
 * age                年龄
 * country            国家
 * onlineStatus       是否在线
 * isFollow           是否公开直播中
 * isFollow           是否关注
 * letterId           信件ID(意向信和EMF)
 * letterSendTime     信件发送时间
 * letterBrief        信件内容
 * hasRead            是否已读
 * hasReplied         是否已回复
 * letterImgList      图片附件列表
 * letterVideoList    视频附件列表
 */
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull anchorCover;
@property (nonatomic, copy) NSString* _Nonnull anchorAvatar;
@property (nonatomic, copy) NSString* _Nonnull anchorNickName;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* _Nonnull country;
@property (nonatomic, assign) BOOL onlineStatus;
@property (nonatomic, assign) BOOL isInPublic;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, copy) NSString* _Nonnull letterId;
@property (nonatomic, assign) NSInteger letterSendTime;
@property (nonatomic, copy) NSString* _Nonnull letterContent;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL hasReplied;
@property (nonatomic, strong) NSMutableArray<LSHttpLetterImgItemObject *>* _Nonnull letterImgList;
@property (nonatomic, strong) NSMutableArray<LSHttpLetterVideoItemObject *>* _Nonnull letterVideoList;
@property (nonatomic, strong) LSScheduleInviteDetailItemObject *_Nullable scheduleInfo;
@property (nonatomic, strong) LSAccessKeyinfoItemObject *_Nullable accessKeyInfo;

@end
