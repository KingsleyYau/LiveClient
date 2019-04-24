//
//  LSLiveChatPrivItemObject.h
//  dating
//
//  Created by Alex on 19/3/19.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
/**
 *  LiveChat权限相关
 *  isLiveChatPriv              LiveChat聊天总权限（NO：禁止，YES：正常，默认：YES）
 *  liveChatInviteRiskType      聊天邀请（LSHTTP_LIVECHATINVITE_RISK_NOLIMIT：不作任何限制 ，
                                     LSHTTP_LIVECHATINVITE_RISK_LIMITSEND：限制发送信息，
                                     LSHTTP_LIVECHATINVITE_RISK_LIMITREV：限制接受邀请，
                                     LSHTTP_LIVECHATINVITE_RISK_LIMITALL：收发全部限制）
 *  isSendLiveChatPhotoPriv    观众发送私密照权限（NO：禁止，YES：正常，默认：YES）
 *  isSendLiveChatVoicePriv    观众发送语音权限（NO：禁止，YES：正常，默认：YES）
 */
@interface LSLiveChatPrivItemObject : NSObject
@property (nonatomic, assign) BOOL isLiveChatPriv;
@property (nonatomic, assign) LSHttpLiveChatInviteRiskType liveChatInviteRiskType;
@property (nonatomic, assign) BOOL isSendLiveChatPhotoPriv;
@property (nonatomic, assign) BOOL isSendLiveChatVoicePriv;

@end
