//
//  LSHangoutStatusItemObject.h
//  dating
//
//  Created by Alex on 19/1/23.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFriendsInfoItemObject.h"
/**
 * Hangout直播信息(ps：当错误码为HTTP_LCC_ERR_EXIST_HANGOUT = 18003才做处理，当前会员已在hangout直播间）
 * liveRoomId               直播间
 * anchorList               主播数组(只有anchorId：主播ID 和 nickName：主播昵称能用)
 */
@interface LSHangoutStatusItemObject : NSObject
@property (nonatomic, copy) NSString *liveRoomId;
@property (nonatomic, strong) NSMutableArray<LSFriendsInfoItemObject *>* anchorList;

@end
