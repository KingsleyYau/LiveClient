//
//  LSAnchorLetterPrivRequest.h
//  dating
//  13.9.获取主播信件权限
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSAnchorLetterPrivRequest : LSSessionRequest
/**
 * anchorId                         主播ID
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) GetAnchorLetterPrivFinishHandler _Nullable finishHandler;
@end
