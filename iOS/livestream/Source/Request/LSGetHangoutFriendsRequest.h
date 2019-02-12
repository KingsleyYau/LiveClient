//
//  LSGetHangoutFriendsRequest.h
//  dating
//  8.8.获取指定主播的Hang-out好友列表
//  Created by Alex on 18/1/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetHangoutFriendsRequest : LSSessionRequest
/**
 * anchorId                         主播ID
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) GetHangoutFriendsFinishHandler _Nullable finishHandler;
@end
