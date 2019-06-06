//
//  LSAddTokenRequest.h
//  dating
//  2.14.添加App token
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

/**
 *  2.14.添加App token接口
 *
 *  tokenId            app token值
 *  appId            app唯一标识（App包名或iOS App ID，详情参考《“App ID”对照表》）
 *  deviceId         设备id
 *  finishHandler    接口回调

 */
@interface LSAddTokenRequest : LSDomainSessionRequest
@property (nonatomic, copy) NSString * _Nullable tokenId;
@property (nonatomic, copy) NSString * _Nullable appId;
@property (nonatomic, copy) NSString * _Nullable deviceId;
@property (nonatomic, strong) AddTokenFinishHandler _Nullable finishHandler;
@end
