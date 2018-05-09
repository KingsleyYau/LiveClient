
//
//  IMAnchorRecommendHangoutItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMAnchorItemObject.h"

@interface IMAnchorRecommendHangoutItemObject : NSObject

/**
 * 推荐好友信息
 * @roomId              直播间ID
 * @anchorId            主播ID
 * @nickName            主播昵称
 * @photoUrl            主播头像
 * @friendId            主播好友ID
 * @friendNickName      主播好友昵称
 * @friendPhotoUrl      主播好友头像
 * @friendAge           年龄
 * @friendCountry       国家
 * @recommendId         邀请ID
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, copy) NSString *_Nonnull friendId;
@property (nonatomic, copy) NSString *_Nonnull friendNickName;
@property (nonatomic, copy) NSString *_Nonnull friendPhotoUrl;
@property (nonatomic, assign) int friendAge;
@property (nonatomic, copy) NSString *_Nonnull friendCountry;
@property (nonatomic, copy) NSString *_Nonnull recommendId;

@end
