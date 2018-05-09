
//
//  ZIMAnchorItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

@interface IMAnchorItemObject : NSObject

/**
 * 已在直播间的主播列表
 * @anchorId                主播ID
 * @anchorNickName          主播昵称
 * @anchorPhotoUrl          主播头像
 */
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull anchorNickName;
@property (nonatomic, copy) NSString *_Nonnull anchorPhotoUrl;


@end
