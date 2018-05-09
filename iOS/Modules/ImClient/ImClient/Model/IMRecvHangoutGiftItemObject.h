
//
//  IMRecvHangoutGiftItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMRecvHangoutGiftItemObject : NSObject

/**
 * 观众端/主播端接收直播间礼物信息
 * @roomId              直播间ID
 * @fromId              发送方的用户ID
 * @nickName            发送方的昵称
 * @toUid               接收者ID（可无，无则表示发送给所有人）
 * @giftId              礼物ID
 * @giftName            礼物名称
 * @giftNum             本次发送礼物的数量
 * @isMultiClick        是否连击礼物（1：是，0：否）
 * @multiClickStart     连击起始数（整型）（可无，multi_click=0则无）
 * @multiClickEnd       连击结束数（整型）（可无，multi_click=0则无）
 * @multiClickId        连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则无）
 * @isPrivate           是否私密发送（YES：是，NO：否）（整型）
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull fromId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull toUid;
@property (nonatomic, copy) NSString *_Nonnull giftId;
@property (nonatomic, copy) NSString *_Nonnull giftName;
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) BOOL isMultiClick;
@property (nonatomic, assign) int multiClickStart;
@property (nonatomic, assign) int multiClickEnd;
@property (nonatomic, assign) int multiClickId;
@property (nonatomic, assign) BOOL isPrivate;

@end
