//
//  ConfigItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigItemObject : NSObject
/**
 * 同步配置结构体
 * imSvrUrl                   IM服务器ip或域名
 * httpSvrUrl                 http服务器ip或域名
 * addCreditsUrl		      充值页面URL
 * anchorPage                 主播资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * userLevel                  观众等级页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * intimacy                   观众与主播亲密度页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
 * userProtocol               观众协议页URL
 * showDetailPage             节目详情页URL
 * showDescription            节目介绍
 * hangoutCredirMsg           多人互动资费提示
 * hangoutCreditPrice         多人互动信用点资费价格
 * loiH5Url                   意向信页URL
 * emfH5Url                   EMF页URL
 * pmStartNotice              私信聊天界面没有聊天记录时的提示
 * pmStartNotice              背包邮票页URL
 * httpSvrMobileUrl           http mobile服务器的URL（包括mobile.charmlive.com或demo-mobile.charmlive.com）
 * sendLetter                 发送信件页URL
 */
@property (nonatomic, copy) NSString *_Nonnull imSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrUrl;
@property (nonatomic, copy) NSString *_Nonnull addCreditsUrl;
@property (nonatomic, copy) NSString *_Nonnull anchorPage;
@property (nonatomic, copy) NSString *_Nonnull userLevel;
@property (nonatomic, copy) NSString *_Nonnull intimacy;
@property (nonatomic, copy) NSString *_Nonnull userProtocol;
@property (nonatomic, copy) NSString *_Nonnull showDetailPage;
@property (nonatomic, copy) NSString *_Nonnull showDescription;
@property (nonatomic, copy) NSString *_Nonnull hangoutCredirMsg;
@property (nonatomic, assign) double hangoutCreditPrice;
@property (nonatomic, copy) NSString *_Nonnull loiH5Url;
@property (nonatomic, copy) NSString *_Nonnull emfH5Url;
@property (nonatomic, copy) NSString *_Nonnull pmStartNotice;
@property (nonatomic, copy) NSString *_Nonnull postStampUrl;
@property (nonatomic, copy) NSString *_Nonnull httpSvrMobileUrl;
@property (nonatomic, copy) NSString *_Nonnull sendLetter;

/*
     test QNLiveChat
 */
@property (nonatomic, copy) NSString *_Nonnull socketHost;
@property (nonatomic, copy) NSString *_Nonnull socketHostDomain;
@property (nonatomic, assign) int socketPort;
@property (nonatomic, copy) NSString *_Nonnull chatVoiceHostUrl;
@property (nonatomic, assign) double minBalanceForChat;
@property (nonatomic, copy) NSString *_Nonnull  webSite;
@property (nonatomic, copy) NSString *_Nonnull appSite;

@end
