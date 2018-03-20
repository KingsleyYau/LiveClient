//
//  LSSetShareSucRequest.h
//  dating
//  6.12.分享链接成功
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSetShareSucRequest : LSSessionRequest
/*
 *  @param shareId          发起分享的主播/观众ID
 */
@property (nonatomic, copy) NSString* _Nonnull shareId;
@property (nonatomic, strong) SetShareSucFinishHandler _Nullable finishHandler;
@end
