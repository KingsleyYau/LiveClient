//
//  LSCheckMailRequest.h
//  dating
//  2.8.检测邮箱注册状态（仅独立）接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCheckMailRequest : LSSessionRequest
/*
 * @param email           电子邮箱
 */
@property (nonatomic, copy) NSString* _Nonnull email;
@property (nonatomic, strong) CheckMailFinishHandler _Nullable finishHandler;
@end
