//
//  LSVersionCheckRequest.h
//  dating
//  6.20.检查客户端更新
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  6.20.检查客户端更新接口
 *
 *  currVersion      当前客户端内部版本号
 *  finishHandler    接口回调

 */
@interface LSVersionCheckRequest : LSSessionRequest
@property (nonatomic, assign) int currVersion;
@property (nonatomic, strong) VersionCheckFinishHandler _Nullable finishHandler;
@end
