//
//  LSSubmitFeedBackRequest.h
//  dating
//  6.13.提交Feedback（仅独立）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSubmitFeedBackRequest : LSSessionRequest
/*
 *  @param mail          用户邮箱
 *  @param msg           feedback内容
 */
@property (nonatomic, copy) NSString* _Nonnull mail;
@property (nonatomic, copy) NSString* _Nonnull msg;
@property (nonatomic, strong) SubmitFeedBackFinishHandler _Nullable finishHandler;
@end
