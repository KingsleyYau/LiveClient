//
//  LSSetPushConfigRequest.h
//  dating
//  11.2.修改推送设置
//  Created by Alex on 18/9/28
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSetPushConfigRequest : LSSessionRequest
// 是否接收私信推送通知
@property (nonatomic, assign) BOOL isPriMsgAppPush;
// 是否接收私信推送通知
@property (nonatomic, assign) BOOL isMailAppPush;
@property (nonatomic, strong) SetPushConfigFinishHandler _Nullable finishHandler;
@end
