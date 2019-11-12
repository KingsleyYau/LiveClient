//
//  GetContactListRequest.h
//  dating
//  3.16.获取我的联系人列表
//  Created by Alex on 19/6/17
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetContactListRequest : LSSessionRequest

@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetContactListFinishHandler _Nullable finishHandler;
@end
