//
//  LiveChatManagerListener.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "IImClient.h"

#import "RoomTopFanItemObject.h"

@protocol IMLiveRoomManagerDelegate <NSObject>
@optional

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

#pragma mark - 直播间主动操作回调
/**
 *  观众进入直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param userId      主播ID
 *  @param nickName    主播昵称
 *  @param photoUrl    主播头像url
 *  @param country     主播国家/地区
 *  @param videoUrls   视频流url（字符串数组）
 *  @param fansNum     观众人数
 *  @param contribute  贡献值
 *  @param fansList    前n个观众信息（用于显示用户头像列表数组）
 *
 */
- (void)onFansRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl country:(NSString* _Nonnull)country videoUrls:(NSArray<NSString*>* _Nonnull)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(NSArray<RoomTopFanItemObject*>* _Nonnull)fansList;
/**
 *  观众退出直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onFansRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;
/**
 *  获取直播间信息回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param fansNum     观众人数
 *  @param contribute  贡献值
 *
 */
- (void)onGetRoomInfo:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg fansNum:(int)fansNum contribute:(int)contribute;

#pragma mark - 直播间接收操作回调
/**
 *  接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *  @param userId      直播ID
 *  @param nickName    直播昵称
 *  @param fansNum     观众人数
 *
 */
- (void)onRecvRoomCloseFans:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName fansNum:(int)fansNum;
/**
 *  接收直播间关闭通知(直播)回调
 *
 *  @param roomId      直播间ID
 *  @param fansNum     观众人数
 *  @param income      收入
 *  @param newFans     新收藏人数
 *  @param shares      分享数
 *  @param duration    直播时长
 *
 */
- (void)onRecvRoomCloseBroad:(NSString* _Nonnull)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration;
/**
 *  接收观众进入直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *
 */
- (void)onRecvFansRoomIn:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl;

#pragma mark - 直播间文本消息信息
/**
 *  发送直播间文本消息回调
 *
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;
/**
 *  接收直播间文本消息通知回调
 *
 *  @param roomId      直播间ID
 *  @param level       发送方级别
 *  @param fromId      发送方的用户ID
 *  @param nickName    发送方的昵称
 *  @param msg         文本消息内容
 *
 */
- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg;

@end
