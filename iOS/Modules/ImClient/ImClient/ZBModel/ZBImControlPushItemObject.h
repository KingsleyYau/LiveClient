//
//  ZBImControlPushItemObject.h
//  dating
//
//  Created by Alex on 18/03/07.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

/**
 * 直播间开播通知结构体
 * roomId                 直播间ID
 * anchorId               观众ID
 * nickName               观众昵称
 * avatarImg              观众头像url
 * control                开关标志（1：启动，2：关闭）
 * manVideoUrl            观众视频流url
 */

@interface ZBImControlPushItemObject : NSObject
@property (nonatomic, copy) NSString* _Nullable roomId;
@property (nonatomic, copy) NSString* _Nullable userId;
@property (nonatomic, copy) NSString* _Nullable nickName;
@property (nonatomic, copy) NSString* _Nullable avatarImg;
@property (nonatomic, assign) ZBIMControlType control;
@property (nonatomic, strong) NSArray<NSString *>* _Nullable manVideoUrl;

@end
