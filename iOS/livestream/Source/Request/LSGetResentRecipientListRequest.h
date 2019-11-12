//
//  LSGetResentRecipientListRequest.h
//  dating
//  15.4.获取Resent Recipient主播列表
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetResentRecipientListRequest : LSSessionRequest

/**
 * 15.4.获取Resent Recipient主播列表接口
 *
 * finishHandler    接口回调
 */
@property (nonatomic, strong) GetResentRecipientListFinishHandler _Nullable finishHandler;
@end
