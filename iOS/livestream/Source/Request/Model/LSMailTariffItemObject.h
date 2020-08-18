//
//  LSMailTariffItemObject.h
//  dating
//
//  Created by Alex on 20/08/05.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSMailPriceItemObject.h"

@interface LSMailTariffItemObject : NSObject
/**
 * 信件资费相关结构体
 * mailSendBase                   发送信件基础资费
 * mailReadBase                   读信基础资费
 * mailPhotoAttachBase       发送信件照片附件基础资费
 * mailPhotoBuyBase           私密照购买基础资费
 * mailVideoBuyBase           视频购买基础资费
 */

@property (nonatomic, strong) LSMailPriceItemObject* _Nullable mailSendBase;
@property (nonatomic, strong) LSMailPriceItemObject* _Nullable mailReadBase;
@property (nonatomic, strong) LSMailPriceItemObject* _Nullable mailPhotoAttachBase;
@property (nonatomic, strong) LSMailPriceItemObject* _Nullable mailPhotoBuyBase;
@property (nonatomic, strong) LSMailPriceItemObject* _Nullable mailVideoBuyBase;


@end
