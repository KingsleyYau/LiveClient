//
//  LSGetDeliveryListRequest.h
//  dating
//  15.5.获取My delivery列表
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetDeliveryListRequest : LSSessionRequest

/**
 * 15.5.获取My delivery列表接口
 *
 * finishHandler    接口回调
 */
@property (nonatomic, strong) GetDeliveryListFinishHandler _Nullable finishHandler;
@end
