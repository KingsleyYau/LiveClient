
//
//  IMOngoingShowItemObject.h
//  livestream
//
//  Created by Max on 2018/5/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMProgramItemObject.h"

@interface IMOngoingShowItemObject : NSObject

/**
 * 将要开播的节目
 * showInfo             节目
 * type                 通知类型（IMPROGRAMNOTICETYPE_BUYTICKET：已购票的通知，IMPROGRAMNOTICETYPE_FOLLOW：仅关注通知）
 * msg                    消息提示文字
 */
@property (nonatomic, strong) IMProgramItemObject *_Nonnull showInfo;
@property (nonatomic, assign) IMProgramNoticeType type;
@property (nonatomic, copy) NSString *_Nonnull msg;


@end
