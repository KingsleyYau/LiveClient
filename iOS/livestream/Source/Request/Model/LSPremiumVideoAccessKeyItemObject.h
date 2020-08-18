//
//  LSPremiumVideoAccessKeyItemObject
//  dating
//
//  Created by Alex on 20/08/04.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSPremiumVideoinfoItemObject.h"
@interface LSPremiumVideoAccessKeyItemObject : NSObject
/**
 * 付费视频解码锁信息结构体
 * requestId                    请求ID
 * premiumVideoInfo     付费视频信息
 * emfId                        信件ID
 * emfReadStatus        信件是否已读（0：否，1：是）
 * validTime                解锁码有效时间(GMT时间戳)
 * lastSendTime         最后请求的时间(GMT时间戳)
 * currentTime          服务器当前时间(GMT时间戳)
 */
@property (nonatomic, copy) NSString* requestId;
@property (nonatomic, strong) LSPremiumVideoinfoItemObject* premiumVideoInfo;
@property (nonatomic, copy) NSString* emfId;
@property (nonatomic, assign) BOOL emfReadStatus;
@property (nonatomic, assign) NSInteger validTime;
@property (nonatomic, assign) NSInteger lastSendTime;
@property (nonatomic, assign) NSInteger currentTime;

@end
