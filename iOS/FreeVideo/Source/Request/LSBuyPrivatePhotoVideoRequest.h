//
//  LSBuyPrivatePhotoVideoRequest.h
//  dating
//  13.7.购买信件附件
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSBuyPrivatePhotoVideoRequest : LSSessionRequest
/**
 * emfId                         信件ID
 * resourceId                    附件ID
 * comsumeType                   付费类型（LSLETTERCOMSUMETYPE_CREDIT：信用点，LSLETTERCOMSUMETYPE_STAMP：邮票）
 */
@property (nonatomic, copy) NSString* _Nullable emfId;
@property (nonatomic, copy) NSString* _Nullable resourceId;
@property (nonatomic, assign) LSLetterComsumeType comsumeType;
@property (nonatomic, strong) BuyPrivatePhotoVideoFinishHandler _Nullable finishHandler;
@end
