//
//  AcceptInstanceInviteRequest.h
//  dating
//  13.8.获取发送信件所需的余额
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetSendMailPriceRequest : LSSessionRequest
// 发送图片附件数
@property (nonatomic, assign) int imgNumber;
@property (nonatomic, strong) GetSendMailPriceFinishHandler _Nullable finishHandler;
@end
