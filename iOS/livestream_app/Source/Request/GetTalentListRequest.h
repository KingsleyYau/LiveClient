//
//  GetTalentListRequest.h
//  dating
//  3.10.获取才艺点播列表接口
//  Created by Alex on 17/8/30
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetTalentListRequest : LSSessionRequest
// 直播间ID
@property (nonatomic, copy) NSString * _Nullable  roomId;
@property (nonatomic, strong) GetTalentListFinishHandler _Nullable finishHandler;
@end
