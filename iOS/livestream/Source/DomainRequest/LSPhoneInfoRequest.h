//
//  LSPhoneInfoRequest.h
//  dating
//  6.22.收集手机硬件信息
//  Created by Alex on 18/11/24
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

/**
 *  6.22.收集手机硬件信息接口
 *
 *  phoneInfo        手机设备资料
 *  finishHandler    接口回调

 */
@interface LSPhoneInfoRequest : LSDomainSessionRequest
@property (nonatomic, strong) LSPhoneInfoObject*_Nullable phoneInfo;
@property (nonatomic, strong) PhoneInfoFinishHandler _Nullable finishHandler;
@end
