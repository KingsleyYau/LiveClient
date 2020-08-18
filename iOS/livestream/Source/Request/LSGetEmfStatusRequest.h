//
//  LSGetEmfStatusRequest.h
//  dating
//  13.10.获取EMF状态
//  Created by Alex on 20/08/13
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetEmfStatusRequest : LSSessionRequest
/**
 * emfId                          信件ID
 */
@property (nonatomic, copy) NSString* _Nullable emfId;
@property (nonatomic, strong) GetEmfStatusFinishHandler _Nullable finishHandler;
@end
