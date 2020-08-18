//
//  LSHttpLetterListItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSHttpLetterListItemObject : NSObject
{

}
/**
 * 信件列表
 * anchorId           主播ID
 * anchorAvatar       主播头像
 * anchorNickName     主播昵称
 * isFollow           是否关注
 * onlineStatus       是否在线
 * letterId         信件ID(意向信和EMF)
 * letterSendTime   信件发送时间
 * letterBrief      信件内容摘要
 * hasImg         是否有照片
 * hasVideo       是否有视频
 * hasRead        是否已读
 * hasReplied     是否已回复
 * hasReplied     是否有预付费直播
 */
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull anchorAvatar;
@property (nonatomic, copy) NSString* _Nonnull anchorNickName;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, assign) BOOL onlineStatus;
@property (nonatomic, copy) NSString* _Nonnull letterId;
@property (nonatomic, assign) NSInteger letterSendTime;
@property (nonatomic, copy) NSString* _Nonnull letterBrief;
@property (nonatomic, assign) BOOL hasImg;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL hasReplied;
@property (nonatomic, assign) BOOL hasSchedule;
@property (nonatomic, assign) BOOL hasKey;//add by albert 20200731
@end
