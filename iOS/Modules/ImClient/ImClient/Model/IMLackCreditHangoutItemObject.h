
//
//  IMLackCreditHangoutItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface IMLackCreditHangoutItemObject : NSObject

/**
 * 多人互动余额不足信息
 * @roomId              直播间ID
 * @anchorId            主播ID
 * @nickName            主播昵称
 * @avatarImg           主播头像
 * @errNo               离开的错误码
 * @errMsg              离开的错误描述
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull avatarImg;
@property (nonatomic, assign) LCC_ERR_TYPE errNo;
@property (nonatomic, copy) NSString *_Nonnull errMsg;


@end
