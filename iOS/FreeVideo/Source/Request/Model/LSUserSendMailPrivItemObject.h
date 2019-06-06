//
//  LSUserSendMailPrivItemObject.h
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
/**
 * 发送照片相关
 *  mailSendPriv        发送照片权限（LSSENDIMGRISKTYPE_NORMAL：正常，LSSENDIMGRISKTYPE_ONLYFREE：只能发免费，LSSENDIMGRISKTYPE_ONLYPAYMENT：只能发付费，LSSENDIMGRISKTYPE_NOSEND：不能发照片）
 *  maxImg              单封信件可发照片最大数
 *  postStampMsg        邮票回复/发送照片提示
 *  coinMsg             信用点回复/发送照片提示
 *  quickPostStampMsg   邮票快速回复照片提示
 *  quickCoinMsg        信用点快速回复照片提示
 */
@interface LSUserSendMailPrivItemObject : NSObject
@property (nonatomic, assign) LSSendImgRiskType mailSendPriv;
@property (nonatomic, assign) int maxImg;
@property (nonatomic, copy) NSString *postStampMsg;
@property (nonatomic, copy) NSString *coinMsg;
@property (nonatomic, copy) NSString *quickPostStampMsg;
@property (nonatomic, copy) NSString *quickCoinMsg;

@end
