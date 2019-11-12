//
//  LSUserPrivItemObject.h
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSHangoutPrivItemObject.h"
#import "LSLiveChatPrivItemObject.h"
#import "LSMailPrivItemObject.h"
/**
 *  信件及意向信权限相关
 *  liveChatPriv        LiveChat权限相关
 *  mailPriv            信件及意向信权限相关
 *  hangoutPriv         Hangout权限相关
 *  isSayHiPriv         SayHi权限(YES:有  NO:无)
 *  isGiftFlowerPriv    是否有鲜花礼品权限
 *  isPublicRoomPriv    观看公开直播限
 */
@interface LSUserPrivItemObject : NSObject
@property (nonatomic, strong) LSLiveChatPrivItemObject* liveChatPriv;
@property (nonatomic, strong) LSMailPrivItemObject* mailPriv;
@property (nonatomic, strong) LSHangoutPrivItemObject* hangoutPriv;
@property (nonatomic, assign) BOOL isSayHiPriv;
@property (nonatomic, assign) BOOL isGiftFlowerPriv;
@property (nonatomic, assign) BOOL isPublicRoomPriv;

@end
