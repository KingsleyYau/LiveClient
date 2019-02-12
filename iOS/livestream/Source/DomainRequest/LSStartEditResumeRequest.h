//
//  LSStartEditResumeRequest.h
//  dating
//  6.21.开始编辑简介触发计时
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

/**
 *  6.21.开始编辑简介触发计时接口
 *
 *  finishHandler    接口回调

 */
@interface LSStartEditResumeRequest : LSDomainSessionRequest
@property (nonatomic, strong) StartEditResumeFinishHandler _Nullable finishHandler;
@end
