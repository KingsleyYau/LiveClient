
//
//  IMAnchorKnockRequestItemObject.h
//  livestream
//
//  Created by Max on 2018/4/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

@interface IMAnchorKnockRequestItemObject : NSObject

/**
 * 敲门回复信息
 * @roomId              直播间ID
 * @userId              敲门的主播ID
 * @nickName            敲门的主播昵称
 * @photoUrl            敲门的主播头像
 * @knockId             敲门ID
 * @type                敲门回复（IMANCHORKNOCKTYPE_AGREE：接受，IMANCHORKNOCKTYPE_REJECT：拒绝，IMANCHORKNOCKTYPE_OUTTIME：邀请超时，IMANCHORKNOCKTYPE_CANCEL：主播取消邀请）
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, copy) NSString *_Nonnull knockId;
@property (nonatomic, assign) IMAnchorKnockType type;
@end
