//
//  ImLoginReturnObject.h
//  dating
//
//  Created by Alex on 17/09/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

/**
 * 直播间开播通知结构体
 * roomId                 直播间ID
 * anchorId               主播ID
 * nickName               主播昵称
 * avatarImg              主播头像url
 * leftSeconds            开播前的倒数秒数（可无，无或0表示立即开播）
 */

@interface ImStartOverRoomObject : NSObject
@property (nonatomic, copy) NSString* _Nullable roomId;
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable nickName;
@property (nonatomic, copy) NSString* _Nullable avatarImg;
@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, strong) NSArray<NSString *>* _Nullable playUrl;

@end
