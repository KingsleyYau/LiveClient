//
// LSGetCanHangoutAnchorListRequest.h
//  dating
//  8.1.获取可邀请多人互动的主播列表
//  Created by Max on 18/04/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetCanHangoutAnchorListRequest : LSSessionRequest
@property (nonatomic, assign) HangoutAnchorListType type;
@property (nonatomic, copy) NSString * _Nullable anchorId;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetCanHangoutAnchorListFinishHandler _Nullable finishHandler;
@end
