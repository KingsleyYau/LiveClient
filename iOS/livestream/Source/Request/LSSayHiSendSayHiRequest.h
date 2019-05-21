//
//  LSSayHiSendSayHiRequest.h
//  dating
//  14.4.发送sayHi
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiSendSayHiRequest : LSSessionRequest
/**
 * anchorId                         主播ID
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
/**
 * themeId                         主题ID
 */
@property (nonatomic, copy) NSString* _Nullable themeId;
/**
 * textId                         文本ID
 */
@property (nonatomic, copy) NSString* _Nullable textId;
@property (nonatomic, strong) SendSayHiFinishHandler _Nullable finishHandler;
@end
