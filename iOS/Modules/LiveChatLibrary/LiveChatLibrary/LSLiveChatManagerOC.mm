//
//  LSLiveChatManagerOC.m
//  LiveChatLibrary
//
//  Created by alex shum on 2018/11/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//
#import "LSLiveChatRequestManager.h"

#include <livechatmanmanager/ILSLiveChatManManager.h>
#include <manrequesthandler/LSLiveChatHttpRequestManager.h>
#import "LSLCLiveChatItem2OCObj.h"
#import "LSLiveChatManagerOC.h"

static LSLiveChatManagerOC *liveChatManager = nil;
@interface LSLiveChatManagerOC () {
    ILSLiveChatManManager *mILSLiveChatManManager;
    ILSLiveChatManManagerListener *mILSLiveChatManManagerListener;
}

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableArray *pushArray;
#pragma mark---- 登录/注销回调处理(OC) ----
- (void)onLoginUser:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg isAutoLogin:(bool)isAutoLogin;
- (void)onLogoutUser:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg isAutoLogin:(bool)isAutoLogin;

#pragma mark---- 在线状态回调处理(OC) ----
- (void)onGetUserStatus:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg userList:(const LCUserList &)userList;
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType;
- (void)onChangeOnlineStatus:(const LSLCUserItem *)userItem;

#pragma mark---- 获取用户资料回调处理(OC) ----
- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg userId:(const char *)userId userInfo:(const UserInfoItem &)userInfo;
//- (void)onGetUsersInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char* )errMsg userInfoList:(const UserInfoList&)userInfoList;
- (void)onGetUsersInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg seq:(int)seq userIdList:(NSArray *)userIdList usersInfo:(const UserInfoList &)usersInfo;
- (void)onGetContactList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg inListType:(CONTACT_LIST_TYPE)inListType userList:(const TalkUserList&)userList;

#pragma mark---- 聊天状态回调处理(OC) ----
- (void)onGetTalkList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg;
- (void)onEndTalk:(const LSLCUserItem *)userItem;
- (void)onRecvTalkEvent:(const LSLCUserItem *)userItem;
- (void)onRecvEMFNotice:(const char *)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType;

#pragma mark---- 文本消息回调处理(OC) ----
- (void)onSendTextMsg:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onSendTextMsgsFail:(LSLIVECHAT_LCC_ERR_TYPE)errType msgList:(const LCMessageList &)msgList;
- (void)onRecvTextMsg:(LSLCMessageItem *)msgItem;
- (void)onRecvSystemMsg:(LSLCMessageItem *)msgItem;
- (void)onRecvWarningMsg:(LSLCMessageItem *)msgItem;
- (void)onRecvEditMsg:(const char *)userId;
- (void)onGetHistoryMessage:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg userItem:(LSLCUserItem *)userItem;
- (void)onGetUsersHistoryMessage:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg userList:(const LCUserList &)userList;
- (void)onSendScheduleInvite:(LSLIVECHAT_LCC_ERR_TYPE)errNo errMsg:(const string &)errMsg item:(LSLCMessageItem *)item scheduleReplyItem:(LSLCMessageItem *)scheduleReplyItem;
- (void)onRecvScheduleInviteNotice:(LSLCMessageItem *)item womanId:(const string &)womanId scheduleReplyItem:(LSLCMessageItem *)scheduleReplyItem;

#pragma mark---- 试聊券回调处理(OC) ----
- (void)onCheckTryTicket:(bool)success errNo:(const char *)errNo errMsg:(const char *)errMsg userId:(const char *)userId status:(CouponStatus)status;
- (void)onUseTryTicket:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg userId:(const char *)userId tickEvent:(TRY_TICKET_EVENT)tickEvent;
- (void)onRecvTryTalkBegin:(LSLCUserItem *)userItem time:(int)time;
- (void)onRecvTryTalkEnd:(LSLCUserItem *)userItem;

#pragma mark---- 私密照回调处理(OC) ----
- (void)onGetPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgList:(const LCMessageList &)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType;
- (void)onPhotoFee:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onRecvPhoto:(LSLCMessageItem *)msgItem;
- (void)onSendPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onCheckPhotoFeeStatus:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;

#pragma mark---- 视频回调处理(OC) ----
- (void)onGetVideo:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(const string &)userId videoId:(const string &)videoId inviteId:(const string &)inviteId videoPath:(const string &)videoPath msgList:(const LCMessageList &)msgList;
- (void)onGetVideoPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg userId:(const string &)userId inviteId:(const string &)inviteId videoId:(const string &)videoId videoType:(VIDEO_PHOTO_TYPE)videoType videoPath:(const string &)videoPath msgList:(const LCMessageList &)msgList;
- (void)onRecvVideo:(LSLCMessageItem *)msgItem;
- (void)onVideoFee:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;

#pragma mark---- 高级表情回调处理(OC) ----
- (void)onGetEmotionConfig:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg otherEmtConItem:(const LSLCOtherEmotionConfigItem &)config;
- (void)onGetEmotionImage:(bool)success emtItem:(const LSLCEmotionItem *)item;
- (void)onGetEmotionPlayImage:(bool)success emtItem:(const LSLCEmotionItem *)item;
- (void)onSendEmotion:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onRecvEmotion:(LSLCMessageItem *)msgItem;

#pragma mark---- 小高级表情回调处理(OC) ----
- (void)onGetMagicIconConfig:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg magicIconConItem:(LSLCMagicIconConfig)config;
- (void)onGetMagicIconSrcImage:(bool)success magicIconItem:(const LSLCMagicIconItem *)item;
- (void)onGetMagicIconThumbImage:(bool)success magicIconItem:(const LSLCMagicIconItem *)item;
- (void)onSendMagicIcon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onRecvMagicIcon:(LSLCMessageItem *)msgItem;

#pragma mark---- Camshare回调处理(OC) ----
- (void)onRecvCamAcceptInvite:(const string &)userId isAccept:(BOOL)isAccept;
- (void)onRecvCamInviteCanCancel:(const string &)userId;
- (void)onRecvCamDisconnect:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(const string &)userId;
- (void)onRecvLadyCamStatus:(const string &)userId isOpenCam:(BOOL)isOpenCam;
- (void)onRecvBackgroundTimeout:(const string &)userId;
- (void)onGetLadyCamStatus:(const string &)inUserId errType:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(const string &)errmsg isOpenCam:(BOOL)isOpenCam;
- (void)onCheckCamCoupon:(bool)success errNo:(const char *)errNo errMsg:(const char *)errMsg userId:(const char *)userId status:(CouponStatus)status couponTime:(int)couponTime;
- (void)onUseCamCoupon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg userId:(const string &)userId;

#pragma mark---- 语音消息回调处理(OC) ----
- (void)onGetVoice:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;
- (void)onRecvVoice:(LSLCMessageItem *)msgItem;
- (void)onSendVoice:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem;

- (void)onTokenOverTimeHandler:(const string &)errMsg;

#pragma mark---- 发送邀请语回调处理（OC）-----
// 为了区分OnRecvMessage,这个使用在Qn冒泡跳转到直播后，发送邀请语成功，如果用OnRecvMessage，直播会再冒泡 (Alex, 2019-07-26)
- (void)onRecvAutoInviteMessage:(LSLCMessageItem *)msgItem;

@end

#pragma mark - LiveChatManManagerListener
class LiveChatManManagerListener : public ILSLiveChatManManagerListener {
  public:
    LiveChatManManagerListener(){};
    virtual ~LiveChatManManagerListener(){};

  public:
#pragma mark---- 登录/注销回调(C++) ----
    void OnLogin(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, bool isAutoLogin) {
        NSLog(@"LSLiveChatManagerOC::errType:%d errMsg:%s", errType, errMsg.c_str());
        if (nil != liveChatManager) {
            [liveChatManager onLoginUser:errType errMsg:errMsg.c_str() isAutoLogin:isAutoLogin];
        }
    };
    void OnLogout(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, bool isAutoLogin) {
        if (nil != liveChatManager) {
            [liveChatManager onLogoutUser:errType errMsg:errMsg.c_str() isAutoLogin:isAutoLogin];
        }
    };

#pragma mark---- 在线状态回调(C++) ----
    void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvKickOffline:kickType];
        }
    };
    void OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg){};
    void OnChangeOnlineStatus(LSLCUserItem *userItem) {
        if (nil != liveChatManager) {
            [liveChatManager onChangeOnlineStatus:userItem];
        }
    };
    void OnGetUserStatus(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, const LCUserList &userList) {
        if (nil != liveChatManager) {
            [liveChatManager onGetUserStatus:errType errMsg:errMsg.c_str() userList:userList];
        }
    };
    void OnUpdateStatus(LSLCUserItem *userItem){};

#pragma mark---- 获取用户资料回调(C++) ----
    void OnGetUserInfo(int seq, const string &userId, LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, const UserInfoItem &userInfo) {
        if (nil != liveChatManager) {
            [liveChatManager onGetUserInfo:errType errMsg:errMsg.c_str() userId:userId.c_str() userInfo:userInfo];
        }
    }
    void OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string &errmsg, int seq, const list<string> &userIdList, const UserInfoList &userList) {
        NSArray *nsUserIdList = [LSLCLiveChatItem2OCObj getStringArray:userIdList];
        if (nil != liveChatManager) {
            [liveChatManager onGetUsersInfo:err errMsg:errmsg.c_str() seq:seq userIdList:nsUserIdList usersInfo:userList];
        }
    }
    
    void OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& userList) {
        if (nil != liveChatManager) {
            [liveChatManager onGetContactList:err errMsg:errmsg.c_str() inListType:inListType userList:userList];
        }
    }

#pragma mark---- 聊天状态回调(C++) ----
    void OnGetTalkList(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg) {
        if (nil != liveChatManager) {
            [liveChatManager onGetTalkList:errType errMsg:errMsg.c_str()];
        }
    };
    void OnEndTalk(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, LSLCUserItem *userItem) {
        if (nil != liveChatManager) {
            [liveChatManager onEndTalk:userItem];
        }
    };
    void OnRecvTalkEvent(LSLCUserItem *userItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvTalkEvent:userItem];
        }
    };

#pragma mark---- 文本消息回调(C++) ----
    void OnRecvEMFNotice(const string &fromId, TALK_EMF_NOTICE_TYPE noticeType) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvEMFNotice:fromId.c_str() noticeType:noticeType];
        }
    };

#pragma mark---- 试聊券回调(C++) ----
    void OnCheckCoupon(bool success, const string &errNo, const string &errMsg, const string &userId, CouponStatus status) {
        if (nil != liveChatManager) {
            [liveChatManager onCheckTryTicket:success errNo:errNo.c_str() errMsg:errMsg.c_str() userId:userId.c_str() status:status];
        }
    };
    void OnRecvTryTalkBegin(LSLCUserItem *userItem, int time) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvTryTalkBegin:userItem time:time];
        }
    };
    void OnRecvTryTalkEnd(LSLCUserItem *userItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvTryTalkEnd:userItem];
        }
    };
    void OnUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string &errmsg, const string &userId, TRY_TICKET_EVENT tickEvent) {
        if (nil != liveChatManager) {
            [liveChatManager onUseTryTicket:err errMsg:errmsg.c_str() userId:userId.c_str() tickEvent:tickEvent];
        }
    };

#pragma mark---- 私密照回调(C++) ----
    void OnRecvEditMsg(const string &fromId) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvEditMsg:fromId.c_str()];
        }
    };
    void OnRecvMessage(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvTextMsg:msgItem];
        }
    };
    void OnRecvSystemMsg(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvSystemMsg:msgItem];
        }
    };
    void OnRecvWarningMsg(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvWarningMsg:msgItem];
        }
    };
    void OnSendTextMessage(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendTextMsg:errType errMsg:errMsg.c_str() msgItem:msgItem];
        }
    };
    void OnSendMessageListFail(LSLIVECHAT_LCC_ERR_TYPE errType, const LCMessageList &msgList) {
        if (nil != liveChatManager) {
            [liveChatManager onSendTextMsgsFail:errType msgList:msgList];
        }
    };
    void OnGetHistoryMessage(bool success, const string &errNo, const string &errMsg, LSLCUserItem *userItem) {
        if (nil != liveChatManager) {
            [liveChatManager onGetHistoryMessage:success errNo:errNo errMsg:errMsg userItem:userItem];
        }
    };
    void OnGetUsersHistoryMessage(bool success, const string &errNo, const string &errMsg, const LCUserList &userList) {
        if (nil != liveChatManager) {
            [liveChatManager onGetUsersHistoryMessage:success errNo:errNo errMsg:errMsg userList:userList];
        }
    };
    
    // Alex, 发送预约邀请
    void OnSendScheduleInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, LSLCMessageItem *msgItem, LSLCMessageItem *msgReplyItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendScheduleInvite:err errMsg:errmsg item:msgItem scheduleReplyItem:msgReplyItem];
        }
    }
    void OnRecvScheduleInviteNotice(const string& womanId, LSLCMessageItem *msgItem, LSLCMessageItem *msgReplyItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvScheduleInviteNotice:msgItem womanId:womanId scheduleReplyItem:msgReplyItem];
        }
    }

#pragma mark---- 高级表情回调(C++) ----
    //获取高级表情配置item（登录成功后manmanager调用，后回调的）
    void OnGetEmotionConfig(bool success, const string &errNo, const string &errMsg, const LSLCOtherEmotionConfigItem &config) {
        if (nil != liveChatManager) {
            [liveChatManager onGetEmotionConfig:success errNo:errNo errMsg:errMsg otherEmtConItem:config];
        }
    };
    void OnGetEmotionImage(bool success, const LSLCEmotionItem *item) {
        if (nil != liveChatManager) {
            [liveChatManager onGetEmotionImage:success emtItem:item];
        }
    };
    void OnGetEmotionPlayImage(bool success, const LSLCEmotionItem *item) {
        if (nil != liveChatManager) {
            [liveChatManager onGetEmotionPlayImage:success emtItem:item];
        }
    };
    void OnRecvEmotion(LSLCMessageItem* msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvEmotion:msgItem];
        }
    };
    void OnSendEmotion(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendEmotion:errType errMsg:errMsg msgItem:msgItem];
        }
    };

#pragma mark---- 语音回调(C++) ----
    void OnRecvVoice(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvVoice:msgItem];
        }
    };

    void OnGetVoice(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onGetVoice:errType errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };

    void OnSendVoice(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendVoice:errType errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    }

#pragma mark---- 私密照回调(C++) ----
    void OnGetPhoto(GETPHOTO_PHOTOSIZE_TYPE sizeType, LSLIVECHAT_LCC_ERR_TYPE errType, const string &errNo, const string &errMsg, const LCMessageList &msgList) {
        if (nil != liveChatManager) {
            [liveChatManager onGetPhoto:errType errNo:errNo errMsg:errMsg msgList:msgList sizeType:sizeType];
        }
    };

    void OnPhotoFee(bool success, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onPhotoFee:success errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };

    void OnRecvPhoto(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvPhoto:msgItem];
        }
    };

    void OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendPhoto:errType errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };

    void OnCheckPhoto(bool success, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onCheckPhotoFeeStatus:success errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };

#pragma mark---- 小视频回调 ----
    void OnGetVideo(LSLIVECHAT_LCC_ERR_TYPE errType,
                    const string &userId,
                    const string &videoId,
                    const string &inviteId,
                    const string &videoPath,
                    const LCMessageList &msgList){
        if (nil != liveChatManager) {
            [liveChatManager onGetVideo:errType userId:userId videoId:videoId inviteId:inviteId videoPath:videoPath msgList:msgList];
        }
    };

    void OnGetVideoPhoto(LSLIVECHAT_LCC_ERR_TYPE errType,
                         const string &errNo,
                         const string &errMsg,
                         const string &userId,
                         const string &inviteId,
                         const string &videoId,
                         VIDEO_PHOTO_TYPE videoType,
                         const string &filePath,
                         const LCMessageList &msgList){
        if (nil != liveChatManager) {
            [liveChatManager onGetVideoPhoto:errType errNo:errNo errMsg:errMsg userId:userId inviteId:inviteId videoId:videoId videoType:videoType videoPath:filePath msgList:msgList];
        }
    };
    void OnRecvVideo(LSLCMessageItem *msgItem){
        if (nil != liveChatManager) {
            [liveChatManager onRecvVideo:msgItem];
        }
    };
    void OnVideoFee(bool success, const string &errNo, const string &errMsg, LSLCMessageItem *msgItem){
        if (nil != liveChatManager) {
            [liveChatManager onVideoFee:success errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };

#pragma mark---- 小高级表情回调(C++) ----
    //获取小高级表情配置item（登录成功后manmanager调用，后回调的）
    void OnGetMagicIconConfig(bool success, const string &errNo, const string &errMsg, const LSLCMagicIconConfig &config) {
        if (nil != liveChatManager) {
            //object = [LiveChatItem2OCObj getLiveChatEmotionConfigItemObject:config];
            //if (nil != object) {
            [liveChatManager onGetMagicIconConfig:success errNo:errNo errMsg:errMsg magicIconConItem:config];
            //}
        }
    };
    void OnGetMagicIconSrcImage(bool success, const LSLCMagicIconItem *item) {
        if (nil != liveChatManager) {
            [liveChatManager onGetMagicIconSrcImage:success magicIconItem:item];
        }
    };
    void OnGetMagicIconThumbImage(bool success, const LSLCMagicIconItem *item) {
        if (nil != liveChatManager) {
            [liveChatManager onGetMagicIconThumbImage:success magicIconItem:item];
        }
    };
    void OnRecvMagicIcon(LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvMagicIcon:msgItem];
        }
    };
    void OnSendMagicIcon(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errMsg, LSLCMessageItem *msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onSendMagicIcon:errType errMsg:errMsg msgItem:msgItem];
        }
    };

#pragma mark---- Camshare回调(C++) ----
    void OnRecvCamAcceptInvite(const string &userId, bool isAccept) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvCamAcceptInvite:userId isAccept:isAccept ? YES : NO];
        }
    }

    void OnRecvCamInviteCanCancel(const string &userId) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvCamInviteCanCancel:userId];
        }
    }

    void OnRecvCamDisconnect(LSLIVECHAT_LCC_ERR_TYPE errType, const string &userId) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvCamDisconnect:errType userId:userId];
        }
    }

    void OnRecvLadyCamStatus(const string &userId, bool isOpenCam) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvLadyCamStatus:userId isOpenCam:isOpenCam];
        }
    }

    void OnRecvBackgroundTimeout(const string &userId) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvBackgroundTimeout:userId];
        }
    }

    void OnGetLadyCamStatus(const string &inUserId, LSLIVECHAT_LCC_ERR_TYPE errType, const string &errmsg, bool isOpenCam) {
        if (nil != liveChatManager) {
            [liveChatManager onGetLadyCamStatus:inUserId errType:errType errmsg:errmsg isOpenCam:isOpenCam];
        }
    }

    void OnCheckCamCoupon(bool success, const string &errNo, const string &errMsg, const string &userId, CouponStatus status, int couponTime) {
        if (nil != liveChatManager) {
            [liveChatManager onCheckCamCoupon:success errNo:errNo.c_str() errMsg:errMsg.c_str() userId:userId.c_str() status:status couponTime:couponTime];
        }
    }

    void OnUseCamCoupon(LSLIVECHAT_LCC_ERR_TYPE errType, const string &errmsg, const string &userId) {
        if (nil != liveChatManager) {
            [liveChatManager onUseCamCoupon:errType errMsg:errmsg.c_str() userId:userId.c_str()];
        }
    }
    
    void OnTokenOverTimeHandler(const string& errNo, const string& errmsg) {
        if (nil != liveChatManager) {
            [liveChatManager onTokenOverTimeHandler:errmsg.c_str()];
        }
    }
    
    // 为了区分OnRecvMessage,这个使用在Qn冒泡跳转到直播后，发送邀请语成功，如果用OnRecvMessage，直播会再冒泡 (Alex, 2019-07-26)
    void OnRecvAutoInviteMessage(LSLCMessageItem* msgItem) {
        if (nil != liveChatManager) {
            [liveChatManager onRecvAutoInviteMessage:msgItem];
        }
    }
};
static LiveChatManManagerListener *gLiveChatManManagerListener;

@implementation LSLiveChatManagerOC

#pragma mark - 获取实例
+ (instancetype)manager {
    if (liveChatManager == nil) {
        liveChatManager = [[[self class] alloc] init];
    }
    return liveChatManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.delegates = [NSMutableArray array];
        self.pushArray = [NSMutableArray array];

        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];

        mILSLiveChatManManager = NULL;
        gLiveChatManManagerListener = new LiveChatManManagerListener();
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        
//        [self createLiveChatManager:@"lc.demo.charmdate.com" port:5004 webSite:@"http://demo.charmdate.com" appSite:@"http://demo-mobile.charmdate.com" chatVoiceHostUrl:@"12435" httpUser:@"test" httpPassword:@"5179" versionCode:@"130" cachesDirectory:cachesDirectory minChat:5.0 minCamshare:6.0];
//
//        [self loginUser:@"cm26525012" userName:@"alex" sid:@"" device:@"12" isRecvVideoMsg:YES livechatInvite:YES isLivechat:YES];
        
    }

    return self;
}

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LSLiveChatManagerListenerDelegate>)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> item = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"LSLiveChatManagerOC::addDelegate() add again, delegate:<%@>", delegate);
                result = YES;
                break;
            }
        }

        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }

    return result;
}

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<LSLiveChatManagerListenerDelegate>)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> item = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    // log
    if (!result) {
        NSLog(@"LSLiveChatManagerOC::removeDelegate() fail, delegate:<%@>", delegate);
    }

    return result;
}

- (int)getNativeSocket {
    return mILSLiveChatManManager->GetSocket();
}

- (BOOL)createLiveChatManager:(NSString *)domain
                         port:(int)port
                      webSite:(NSString *)webSite
                      appSite:(NSString *)appSite
             chatVoiceHostUrl:(NSString *)chatVoiceHostUrl
                     httpUser:(NSString *)httpUser
                 httpPassword:(NSString *)httpPassword
                  versionCode:(NSString *)versionCode
                        appId:(NSString *)appId
              cachesDirectory:(NSString *)cachesDirectory
                      minChat:(double)minChat {
    BOOL result = NO;

    if (NULL != mILSLiveChatManManager) {
        list<string> ipItemList;
        ipItemList.push_back([domain UTF8String]);
        string strWebSite = "";
        if (nil != webSite) {
            strWebSite = [webSite UTF8String];
        }
        string strAppSite = "";
        if (nil != appSite) {
            strAppSite = [appSite UTF8String];
        }
        string strChatVoiceHostUrl = "";
        if (nil != chatVoiceHostUrl) {
            strChatVoiceHostUrl = [chatVoiceHostUrl UTF8String];
        }
        string strHttpUser = "";
        if (nil != httpUser) {
            strHttpUser = [httpUser UTF8String];
        }
        string strHttpPassword = "";
        if (nil != httpPassword) {
            strHttpPassword = [httpPassword UTF8String];
        }
        string strVersionCode = "";
        if (nil != versionCode) {
            strVersionCode = [versionCode UTF8String];
        }
        string strAppId = "";
        if (nil != appId) {
            strAppId = [appId UTF8String];
        }
        string strCachesDirectory = "";
        if (nil != cachesDirectory) {
            strCachesDirectory = [cachesDirectory UTF8String];
        }
        result = mILSLiveChatManManager->Init(ipItemList, port, OTHER_SITE_LIVE, strWebSite, strAppSite, strChatVoiceHostUrl, strHttpUser, strHttpPassword, strVersionCode, strAppId, strCachesDirectory, minChat, 0.0, gLiveChatManManagerListener);
    }

    NSLog(@"LSLiveChatRequestManager::createLiveChatManager( domain : %@,  result: %d)", domain, result);
    return result;
}

- (void)releaseLiveChatManager {
    if (NULL != mILSLiveChatManManager) {
        ILSLiveChatManManager::Release(mILSLiveChatManManager);
        mILSLiveChatManManager = NULL;
    }
}

- (BOOL)loginUser:(NSString *)domain
             port:(int)port
          webSite:(NSString *)webSite
          appSite:(NSString *)appSite
 chatVoiceHostUrl:(NSString *)chatVoiceHostUrl
         httpUser:(NSString *)httpUser
     httpPassword:(NSString *)httpPassword
      versionCode:(NSString *)versionCode
            appId:(NSString *)appId
  cachesDirectory:(NSString *)cachesDirectory
          minChat:(double)minChat
             user:(NSString *)user
         userName:(NSString *)userName
              sid:(NSString *)sid
           device:(NSString *)device
   livechatInvite:(NSInteger)livechatInvite
       isLivechat:(BOOL)isLiveChat
  isSendPhotoPriv:(BOOL)isSendPhotoPriv
   isLiveChatPriv:(BOOL)isLiveChatPriv
  isSendVoicePriv:(BOOL)isSendVoicePriv{
    BOOL result = NO;
    if (NULL == mILSLiveChatManManager) {
         mILSLiveChatManManager = ILSLiveChatManManager::Create();
        if (NULL != mILSLiveChatManManager) {
            result = [self createLiveChatManager:domain port:port webSite:webSite appSite:appSite chatVoiceHostUrl:chatVoiceHostUrl httpUser:httpUser httpPassword:httpPassword versionCode:versionCode appId:appId cachesDirectory:cachesDirectory minChat:minChat];
        }
    } else {
        if (mILSLiveChatManManager->IsLogin()) {
            mILSLiveChatManManager->Logout(false);
        }
        result = YES;
    }
    
        string strUser = "";
        if (nil != user) {
            strUser = [user UTF8String];
        }

        string strUserName = "";
        if (nil != userName) {
            strUserName = [userName UTF8String];
        }

        string strSid = "";
        if (nil != sid) {
            strSid = [sid UTF8String];
        }

        string strDevice = "";
        if (nil != device) {
            strDevice = [device UTF8String];
        }
        

    result = result &&mILSLiveChatManManager->Login(strUser, strUserName, strSid, CLIENT_IPHONE, HttpClient::GetCookiesInfo(), strDevice, GetliveChatInviteRiskType((int)livechatInvite), isLiveChat, YES, isSendPhotoPriv, isLiveChatPriv, isSendVoicePriv);
    NSLog(@"LSLiveChatRequestManager::loginUser( user : %@,  sid: %@)", user, sid);
    return result;
}

- (void)onLoginUser:(LSLIVECHAT_LCC_ERR_TYPE)errType
             errMsg:(const char *)errMsg
        isAutoLogin:(bool)isAutoLogin {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    BOOL bIsAutoLogin = isAutoLogin ? YES : NO;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onLogin:errMsg:isAutoLogin:)]) {
                [delegate onLogin:errType errMsg:nssErrMsg isAutoLogin:bIsAutoLogin];
            }
        }
    }
}


- (void)logoutUser:(BOOL)isResetParam {
    NSLog(@"LiveChatManager::logoutUser( [Livechat注销], isResetParam : %d )", isResetParam);
    if (NULL != mILSLiveChatManManager) {
        mILSLiveChatManManager->Logout(isResetParam ? true : false);
        if (isResetParam) {
            [self releaseLiveChatManager];
        }
    }
}

- (void)onLogoutUser:(LSLIVECHAT_LCC_ERR_TYPE)errType
              errMsg:(const char *)errMsg
         isAutoLogin:(bool)isAutoLogin {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    BOOL bIsAutoLogin = isAutoLogin ? YES : NO;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onLogout:errmsg:isAutoLogin:)]) {
                [delegate onLogout:errType errmsg:nssErrMsg isAutoLogin:bIsAutoLogin];
            }
        }
    }
}

#pragma mark - 在线状态
- (void)relogin {
    if (NULL != mILSLiveChatManManager) {
        mILSLiveChatManManager->Relogin();
    }
}

- (BOOL)isLogin {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        result = mILSLiveChatManManager->IsLogin() ? YES : NO;
    }
    return result;
}

- (BOOL)getUserStatus:(NSArray<NSString *> *)userIds {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        list<string> userIdsList = [LSLCLiveChatItem2OCObj getStringList:userIds];
        result = mILSLiveChatManManager->GetUserStatus(userIdsList) ? YES : NO;
    }
    return result;
}

- (BOOL)endTalk:(NSString *)userId {

    return [self endTalk:userId isLiveChat:YES];
}

- (BOOL)endTalk:(NSString *)userId isLiveChat:(BOOL)isLiveChat {

    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        result = mILSLiveChatManManager->EndTalk(strUserId, isLiveChat) ? YES : NO;
    }
    return result;
}

- (void)endTalkAll {
    if (NULL != mILSLiveChatManManager) {
        LCUserList userList = mILSLiveChatManManager->GetChatingUsers();
        for (LCUserList::const_iterator itr = userList.begin(); itr != userList.end(); itr++) {
            LSLCUserItem *user = *itr;
            if (user != NULL) {
                mILSLiveChatManManager->EndTalkWithNoType(user->m_userId);
            }
        }
    }
}

- (BOOL)isNoMoneyWithErrCode:(NSString *)errCode {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strErrCode = "";
        if (errCode != nil) {
            strErrCode = [errCode UTF8String];
        }
        result = mILSLiveChatManManager->IsNoMoneyWithErrCode(strErrCode);
    }
    return result;
}

//判断是否有风控
- (BOOL)iniviteMsgIsRiskControl:(LSLCLiveChatMsgItemObject *)msgObj {
    return NO;
}

- (void)onGetUserStatus:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg userList:(const LCUserList &)userList {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSArray<LSLCLiveChatUserItemObject *> *users = [LSLCLiveChatItem2OCObj getLiveChatUserArray:userList];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetUserStatus:errMsg:users:)]) {
                [delegate onGetUserStatus:errType errMsg:nssErrMsg users:users];
            }
        }
    }
}

- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvKickOffline:)]) {
                [delegate onRecvKickOffline:kickType];
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self logoutUser:YES];
    });
}

- (void)onChangeOnlineStatus:(const LSLCUserItem *)userItem {
    LSLCLiveChatUserItemObject *userObj = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    if (nil != userObj) {
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onChangeOnlineStatus:)]) {
                    [delegate onChangeOnlineStatus:userObj];
                }
            }
        }
    }
}

#pragma mark - 获取用户信息
- (BOOL)getUserInfo:(NSString *)userId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        result = mILSLiveChatManManager->GetUserInfo(strUserId) ? YES : NO;
    }
    return result;
}

- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg userId:(const char *)userId userInfo:(const UserInfoItem &)userInfo {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString *nsUserId = [NSString stringWithUTF8String:userId];
    LSLCLiveChatUserInfoItemObject *userInfoObject = [LSLCLiveChatItem2OCObj getLiveChatUserInfoItemObjecgt:userInfo];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetUserInfo:errMsg:userId:userInfo:)]) {
                [delegate onGetUserInfo:errType errMsg:nsErrMsg userId:nsUserId userInfo:userInfoObject];
            }
        }
    }
}

- (int)getUsersInfo:(NSArray<NSString *> *)userIds {
    //    BOOL result = NO;
    int seq = HTTPREQUEST_INVALIDREQUESTID;
    if (NULL != mILSLiveChatManManager) {
        list<string> userIdList = [LSLCLiveChatItem2OCObj getStringList:userIds];
        //        result = mILSLiveChatManManager->GetUsersInfo(userIdList) ? YES : NO;
        seq = mILSLiveChatManManager->GetUsersInfo(userIdList);
    }
    return seq;
    //    return result;
}
- (NSString *)getMyServer {
    return [NSString stringWithUTF8String:mILSLiveChatManManager->GetMyServer().c_str()];
}

- (void)onGetUsersInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg seq:(int)seq userIdList:(NSArray *)userIdList usersInfo:(const UserInfoList &)usersInfo {
    NSLog(@"LiveChatManager::onGetUsersInfo( 获取用户信息回调 errType : %d )", errType);
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg];
    NSArray<LSLCLiveChatUserInfoItemObject *> *usersInfoObj = [LSLCLiveChatItem2OCObj getLiveChatUserInfoArray:usersInfo];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetUsersInfo:errMsg:seq:userIdList:usersInfo:)]) {
                [delegate onGetUsersInfo:errType errMsg:nsErrMsg seq:seq userIdList:userIdList usersInfo:usersInfoObj];
            }
        }
    }
}

- (void)onGetContactList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg inListType:(CONTACT_LIST_TYPE)inListType userList:(const TalkUserList&)userList {
    NSLog(@"LiveChatManager::onGetContactList( 联系人列表信息回调 errType : %d )", errType);
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg];
    NSArray<LSLCLiveChatUserInfoItemObject *> *usersInfoObj = [LSLCLiveChatItem2OCObj getLiveChatUserInfoArray:userList];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetContactList:errMsg:usersInfo:)]) {
                [delegate onGetContactList:errType errMsg:nsErrMsg usersInfo:usersInfoObj];
            }
        }
    }
}

#pragma mark - 聊天状态回调
- (void)onGetTalkList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetTalkList:errMsg:)]) {
                [delegate onGetTalkList:errType errMsg:nssErrMsg];
            }
        }
    }
}

- (void)onEndTalk:(const LSLCUserItem *)userItem {
    LSLCLiveChatUserItemObject *user = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onEndTalk:)]) {
                [delegate onEndTalk:user];
            }
        }
    }
}

- (void)onRecvTalkEvent:(const LSLCUserItem *)userItem {
    LSLCLiveChatUserItemObject *user = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvTalkEvent:)]) {
                [delegate onRecvTalkEvent:user];
            }
        }
    }
}

#pragma mark - notice
- (void)onRecvEMFNotice:(const char *)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType {
    NSString *nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEMFNotice:noticeType:)]) {
                [delegate onRecvEMFNotice:nssUserId noticeType:noticeType];
            }
        }
    }
}

#pragma mark - 试聊券
- (BOOL)checkTryTicket:(NSString *)userId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        result = mILSLiveChatManManager->CheckCoupon(strUserId) ? YES : NO;
    }
    return result;
}

- (void)onCheckTryTicket:(bool)success
                   errNo:(const char *)errNo
                  errMsg:(const char *)errMsg
                  userId:(const char *)userId
                  status:(CouponStatus)status {
    BOOL bSuccess = success ? YES : NO;
    NSString *nssErrNo = [NSString stringWithUTF8String:errNo];
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString *nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onCheckTryTicket:errNo:errMsg:userId:status:)]) {
                [delegate onCheckTryTicket:bSuccess errNo:nssErrNo errMsg:nssErrMsg userId:nssUserId status:status];
            }
        }
    }
}

- (void)onUseTryTicket:(LSLIVECHAT_LCC_ERR_TYPE)errType
                errMsg:(const char *)errMsg
                userId:(const char *)userId
             tickEvent:(TRY_TICKET_EVENT)tickEvent {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString *nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onUseTryTicket:errMsg:userId:tickEvent:)]) {
                [delegate onUseTryTicket:errType errMsg:nssErrMsg userId:nssUserId tickEvent:tickEvent];
            }
        }
    }
}

- (void)onRecvTryTalkBegin:(LSLCUserItem *)userItem
                      time:(int)time {
    LSLCLiveChatUserItemObject *userObj = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    NSInteger nsiTime = time;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvTryTalkBegin:time:)]) {
                [delegate onRecvTryTalkBegin:userObj time:nsiTime];
            }
        }
    }
}


- (void)onRecvTryTalkEnd:(LSLCUserItem *)userItem {
    LSLCLiveChatUserItemObject *userObj = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvTryTalkEnd:)]) {
                [delegate onRecvTryTalkEnd:userObj];
            }
        }
    }
}

#pragma mark - 公共操作

- (NSArray<LSLCLiveChatMsgItemObject *> *)getMsgsWithUser:(NSString *)userId {
    NSMutableArray<LSLCLiveChatMsgItemObject *> *msgs = [NSMutableArray array];
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        LSLCUserItem *userItem = mILSLiveChatManManager->GetUserWithId(strUserId);
        if (NULL != userItem) {
            //            userItem->LockMsgList();
            LCMessageList msgList = userItem->GetMsgList();
            for (list<LSLCMessageItem *>::iterator iter = msgList.begin();
                 iter != msgList.end();
                 iter++) {
                LSLCMessageItem *msgItem = (*iter);
                LSLCLiveChatMsgItemObject *obj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
                if (nil != obj) {
                    [msgs addObject:obj];
                }
            }
            //            userItem->UnlockMsgList();
        }
    }
    return msgs;
}

- (LSLCLiveChatUserItemObject *)getUserWithId:(NSString *)userId {
    LSLCLiveChatUserItemObject *userObj = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        LSLCUserItem *userItem = mILSLiveChatManManager->GetUserWithId(strUserId);
        userObj = [LSLCLiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    }
    return userObj;
}

- (NSArray<LSLCLiveChatUserItemObject *> *)getInviteUsers {
    NSArray<LSLCLiveChatUserItemObject *> *users = [NSArray array];
    if (NULL != mILSLiveChatManManager) {
        LCUserList userList = mILSLiveChatManManager->GetInviteUsers();
        users = [LSLCLiveChatItem2OCObj getLiveChatUserArray:userList];
    }

    return users;
}

- (NSArray<LSLCLiveChatUserItemObject *> *)getChatingUsers {
    NSArray<LSLCLiveChatUserItemObject *> *users = [NSArray array];
    if (NULL != mILSLiveChatManManager) {
        LCUserList userList = mILSLiveChatManManager->GetChatingUsers();
        users = [LSLCLiveChatItem2OCObj getLiveChatUserArray:userList];
    }
    return users;
}

- (BOOL)isChatingUserInChatState:(NSString *)womanId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strWomanId = "";
        if (womanId != nil) {
            strWomanId = [womanId UTF8String];
        }
        result = mILSLiveChatManManager->IsChatingUserInChatState(strWomanId);
    }
    return result;
}

- (NSArray<LSLCLiveChatUserItemObject *> *)getManInviteUsers {
    NSArray<LSLCLiveChatUserItemObject *> *users = [NSArray array];
    if (NULL != mILSLiveChatManManager) {
        LCUserList userList = mILSLiveChatManManager->GetManInviteUsers();
        users = [LSLCLiveChatItem2OCObj getLiveChatUserArray:userList];
    }
    return users;
}

- (BOOL)isInManInvite:(NSString *)womanId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strWomanId = "";
        if (womanId != nil) {
            strWomanId = [womanId UTF8String];
        }
        result = mILSLiveChatManManager->IsInManInvite(strWomanId);
    }
    return result;
}


- (BOOL)isInManInviteCanCancel:(NSString *)womanId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strWomanId = "";
        if (womanId != nil) {
            strWomanId = [womanId UTF8String];
        }
        result = mILSLiveChatManManager->IsInManInviteCanCancel(strWomanId);
    }
    return result;
}

- (NSArray<LSLCLiveChatMsgItemObject *> *)getPrivateAndVideoMessageList:(NSString *)userId {
    NSArray<LSLCLiveChatMsgItemObject *> *msgList = [NSArray array];
    if (NULL != mILSLiveChatManManager) {
        string strWomanId = "";
        if (userId != nil) {
            strWomanId = [userId UTF8String];
        }
        LCMessageList list = mILSLiveChatManManager->GetPrivateAndVideoMessageList(strWomanId);
        msgList = [LSLCLiveChatItem2OCObj getLiveChatMsgArray:list];
    }
    return msgList;
}

#pragma mark - 普通消息处理（文本/历史聊天消息等）
- (LSLCLiveChatMsgItemObject *)sendTextMsg:(NSString *)userId text:(NSString *)text {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strText = "";
        if (text != nil) {
            strText = [text UTF8String];
        }
        LSLCMessageItem *msgItem = mILSLiveChatManManager->SendTextMessage(strUserId, strText);
        if (NULL != msgItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

- (void)onSendTextMsg:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const char *)errMsg msgItem:(LSLCMessageItem *)msgItem {
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendTextMsg:errMsg:msgItem:)]) {
                [delegate onSendTextMsg:errType errMsg:nssErrMsg msgItem:msgObj];
            }
        }
    }
}

- (void)onSendTextMsgsFail:(LSLIVECHAT_LCC_ERR_TYPE)errType msgList:(const LCMessageList &)msgList {
    NSArray<LSLCLiveChatMsgItemObject *> *msgs = [LSLCLiveChatItem2OCObj getLiveChatMsgArray:msgList];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendTextMsgsFail:msgs:)]) {
                [delegate onSendTextMsgsFail:errType msgs:msgs];
            }
        }
    }
}

- (void)onRecvTextMsg:(LSLCMessageItem *)msgItem {

    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];

    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvTextMsg:)]) {
                [delegate onRecvTextMsg:msgObj];
            }
        }
    }

}

- (void)onRecvSystemMsg:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];

    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvSystemMsg:)]) {
                [delegate onRecvSystemMsg:msgObj];
            }
        }
    }
}

- (void)onRecvWarningMsg:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];

    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvWarningMsg:)]) {
                [delegate onRecvWarningMsg:msgObj];
            }
        }
    }
}

- (void)onRecvEditMsg:(const char *)userId {
    NSString *nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEditMsg:)]) {
                [delegate onRecvEditMsg:nssUserId];
            }
        }
    }
}


- (void)onGetHistoryMessage:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg userItem:(LSLCUserItem *)userItem {
    NSString *nsUserId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetHistoryMessage:errNo:errMsg:userId:)]) {
                [delegate onGetHistoryMessage:success errNo:nsErrNo errMsg:nsErrMsg userId:nsUserId];
            }
        }
    }
}

- (void)onGetUsersHistoryMessage:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg userList:(const LCUserList &)userList {
    NSArray<NSString *> *nsUserIds = [LSLCLiveChatItem2OCObj getLiveChatUserIdArray:userList];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetUsersHistoryMessage:errNo:errMsg:userIds:)]) {
                [delegate onGetUsersHistoryMessage:success errNo:nsErrNo errMsg:nsErrMsg userIds:nsUserIds];
            }
        }
    }
}

- (void)onSendScheduleInvite:(LSLIVECHAT_LCC_ERR_TYPE)errNo errMsg:(const string &)errMsg item:(LSLCMessageItem *)item scheduleReplyItem:(LSLCMessageItem *)scheduleReplyItem {
    LSLCLiveChatMsgItemObject *obj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:item];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    LSLCLiveChatMsgItemObject *replyObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:scheduleReplyItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendScheduleInvite:errMsg:item:msgReplyItem:)]) {
                [delegate onSendScheduleInvite:errNo errMsg:nsErrMsg item:obj msgReplyItem:replyObj];
            }
        }
    }
}
- (void)onRecvScheduleInviteNotice:(LSLCMessageItem *)item womanId:(const string &)womanId scheduleReplyItem:(LSLCMessageItem *)scheduleReplyItem {
    LSLCLiveChatMsgItemObject *obj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:item];
    NSString *nsWomanId = [NSString stringWithUTF8String:womanId.c_str()];
    LSLCLiveChatMsgItemObject *replyObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:scheduleReplyItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvScheduleInviteNotice:womanId:scheduleReplyItem:)]) {
                [delegate onRecvScheduleInviteNotice:obj womanId:nsWomanId scheduleReplyItem:replyObj];
            }
        }
    }
}

- (StatusType)getMsgStatus:(NSString *)userId msgId:(NSInteger)msgId {
    StatusType statusType = StatusType_Fail;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        int iMsgId = (int)msgId;
        statusType = mILSLiveChatManManager->GetMessageItemStatus(strUserId, iMsgId);
    }
    return statusType;
}

- (NSInteger)insertHistoryMessage:(NSString *)userId msg:(LSLCLiveChatMsgItemObject *)msg {
    NSInteger msgId = -1;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        LSLCMessageItem *msgItem = [LSLCLiveChatItem2OCObj getLiveChatMsgItem:msg];
        if (mILSLiveChatManManager->InsertHistoryMessage(strUserId, msgItem)) {
            msgId = msgItem->m_msgId;
        }
    }
    return msgId;
}

- (BOOL)removeHistoryMessage:(NSString *)userId msgId:(NSInteger)msgId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        int iMsgId = (int)msgId;
        result = mILSLiveChatManManager->RemoveHistoryMessage(strUserId, iMsgId);
    }
    return result;
}

- (LSLCLiveChatMsgItemObject *)getLastMsg:(NSString *)userId {
    LSLCLiveChatMsgItemObject *object = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        // 使用GetTheOtherLastMessage，返回的指针导致异步释放msgItem，导致crash
//        LSLCMessageItem *msgItem = mILSLiveChatManManager->GetLastMessage(strUserId);
//        object = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        LSLCMessageItem msgItem;
        if (mILSLiveChatManManager->GetOtherUserLastMessage(strUserId, msgItem)) {
            object = [LSLCLiveChatItem2OCObj getLiveChatLastMsgItemObject:msgItem];
        }
    }
    return object;
}

- (LSLCLiveChatMsgItemObject *)getTheOtherLastMessage:(NSString *)userId {
    LSLCLiveChatMsgItemObject *object = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        // 使用GetTheOtherLastMessage，返回的指针导致异步释放msgItem，导致crash
//        LSLCMessageItem *msgItem = mILSLiveChatManManager->GetTheOtherLastMessage(strUserId);
//        object = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        LSLCMessageItem msgItem;
        if ( mILSLiveChatManManager->GetOtherUserLastRecvMessage(strUserId, msgItem)) {
            object = [LSLCLiveChatItem2OCObj getLiveChatLastMsgItemObject:msgItem];
        }
    }
    return object;
}

#pragma mark - 私密照消息处理

- (LSLCLiveChatMsgItemObject *)sendPhoto:(NSString *)userId PhotoPath:(NSString *)photoPath {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strPhotoPath = "";
        if (photoPath != nil) {
            strPhotoPath = [photoPath UTF8String];
        }
        LSLCMessageItem *msgItem = mILSLiveChatManManager->SendPhoto(strUserId, strPhotoPath);
        if (NULL != msgItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

- (BOOL)photoFee:(NSString *)userId mphotoId:(NSString *)photoId inviteId:(NSString *)inviteId {

    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strPhotoId = "";
        if (photoId != nil) {
            strPhotoId = [photoId UTF8String];
        }
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        result = mILSLiveChatManManager->PhotoFee(strUserId, strPhotoId, strInviteId);
        //result = mILSLiveChatManManager->CheckPhoto(pUserId, pPhotoId);
    }

    return result;
}

- (BOOL)getPhoto:(NSString *)userId photoId:(NSString *)photoId sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType sendType:(SendType)sendType {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strPhotoId = "";
        if (photoId != nil) {
            strPhotoId = [photoId UTF8String];
        }
        result = mILSLiveChatManManager->GetPhoto(strUserId, strPhotoId, sizeType, sendType);
    }

    return result;
}

- (BOOL)checkPhoto:(NSString *)userId mphotoId:(NSString *)photoId {

    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strPhotoId = "";
        if (photoId != nil) {
            strPhotoId = [photoId UTF8String];
        }
        result = mILSLiveChatManManager->CheckPhoto(strUserId, strPhotoId);
    }

    return result;
}

- (BOOL)sendInviteMessage:(NSString *)userId message:(NSString *)message nickName:(NSString *)nickName {
    
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string stMessage = "";
        if (message != nil) {
            stMessage = [message UTF8String];
        }
        string strNickName = "";
        if (nickName != nil) {
            strNickName = [nickName UTF8String];
        }
        result = mILSLiveChatManManager->SendInviteMessage(strUserId, stMessage, strNickName);
    }
    
    return result;
}

/**
 *  获取用户图片信息
 *
 *  @param errType 结果类型
 *  @param errNo   结果编号
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onGetPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgList:(const LCMessageList &)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType {
    NSArray<LSLCLiveChatMsgItemObject *> *msgListObj = [LSLCLiveChatItem2OCObj getLiveChatMsgArray:msgList];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetPhoto:errNo:errMsg:msgList:sizeType:)]) {
                [delegate onGetPhoto:errType errNo:nsErrNo errMsg:nsErrMsg msgList:msgListObj sizeType:sizeType];
            }
        }
    }
}

/**
 *  获取收费的图片
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onPhotoFee:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onPhotoFee:errNo:errMsg:msgItem:)]) {
                [delegate onPhotoFee:success errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}

/**
 检查收费图片
 
 @param success 操作是否成功
 @param errNo   结果类型
 @param errMsg  结果描述
 @param msgItem 消息
 */
- (void)onCheckPhotoFeeStatus:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onCheckPhotoFeeStatus:errNo:errMsg:msgItem:)]) {
                [delegate onCheckPhotoFeeStatus:success errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}

#pragma mark - 视频消息处理
-(BOOL)getVideoPhoto:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString* _Nonnull)inviteId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        result = mILSLiveChatManManager->GetVideoPhoto(strUserId, strVideoId, strInviteId);
    }
    return result;
}

-(BOOL)videoFee:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString * _Nonnull)inviteId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        
        result = mILSLiveChatManManager->VideoFee(strUserId, strVideoId, strInviteId);
    }
    return result;
}

-(BOOL)getVideo:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString* _Nonnull)inviteId videoUrl:(NSString* _Nonnull)videoUrl msgId:(int)msgId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        string strVideoUrl = "";
        if (videoUrl != nil) {
            strVideoUrl = [videoUrl UTF8String];
        }
        result = mILSLiveChatManManager->GetVideo(strUserId, strVideoId, strInviteId, strVideoUrl, msgId);
    }
    return result;
}

-(BOOL)isGetingVideo:(NSString* _Nonnull)videoId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager) {
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        result = mILSLiveChatManManager->IsGetingVideo(strVideoId);
    }
    return result;
}

-(NSString* _Nonnull)getVideoPhotoPathWithExist:(NSString* _Nonnull)userId inviteId:(NSString* _Nonnull)inviteId videoId:(NSString* _Nonnull)videoId type:(VIDEO_PHOTO_TYPE)type {
    NSString* path = @"";
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        path = [NSString stringWithUTF8String:(mILSLiveChatManManager->GetVideoPhotoPathWithExist(strUserId, strInviteId, strVideoId, type)).c_str()];
    }
    return path;
}

-(NSString* _Nonnull)getVideoPathWithExist:(NSString* _Nonnull)userId inviteId:(NSString* _Nonnull)inviteId videoId:(NSString* _Nonnull)videoId {
    NSString* path = @"";
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strInviteId = "";
        if (inviteId != nil) {
            strInviteId = [inviteId UTF8String];
        }
        string strVideoId = "";
        if (videoId != nil) {
            strVideoId = [videoId UTF8String];
        }
        mILSLiveChatManManager->GetVideoPathWithExist(strUserId, strInviteId, strVideoId);
    }
    return path;
}

-(LSLCLiveChatMsgItemObject *)sendScheduleInvite:(NSString* _Nonnull)userId scheduleItem:(LSLCLiveChatScheduleMsgItemObject * _Nonnull)scheduleItem {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        LSLCMessageItem* msgItem = new LSLCMessageItem;
        //msgItem->m_fromId = [scheduleItem.manId UTF8String];
        //msgItem->m_inviteId = [scheduleItem.inviteId UTF8String];
        //msgItem->m_sendType = SendType_Send;
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        LSLCScheduleInviteItem* scheduleMsgItem = [LSLCLiveChatItem2OCObj getLiveChatScheduleInviteItem:scheduleItem];
        
        msgItem->SetScheduleInviteItem(scheduleMsgItem);

        LSLCMessageItem *msgScheduleItem = mILSLiveChatManManager->SendScheduleInvite(strUserId, msgItem);
        if (NULL != msgScheduleItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgScheduleItem];
        }
    }
    return msgObj;
}

-(LSLCLiveChatMsgItemObject *)acceptOrDeclineScheduleInvite:(LSLCLiveChatMsgItemObject * _Nonnull)infoItem {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        LSLCMessageItem* item = [LSLCLiveChatItem2OCObj getLiveChatMsgItem:infoItem] ;

        LSLCMessageItem *msgScheduleItem =  mILSLiveChatManManager->SendScheduleInvite(item->m_fromId, item);
        if (NULL != msgScheduleItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgScheduleItem];
        }
    }
    return msgObj;
}


#pragma mark - 视频消息处理回调
- (void)onGetVideo:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(const string &)userId videoId:(const string &)videoId inviteId:(const string &)inviteId videoPath:(const string &)videoPath msgList:(const LCMessageList &)msgList {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsVideoId = [NSString stringWithUTF8String:videoId.c_str()];
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsVideoPath = [NSString stringWithUTF8String:videoPath.c_str()];
    NSArray<LSLCLiveChatMsgItemObject *> *msgListObj = [LSLCLiveChatItem2OCObj getLiveChatMsgArray:msgList];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetVideo:userId:videoId:inviteId:videoPath:msgList:)]) {
                [delegate onGetVideo:errType userId:nsUserId videoId:nsVideoId inviteId:nsInviteId videoPath:nsVideoPath msgList:msgListObj];
            }
        }
    }
}
- (void)onGetVideoPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg userId:(const string &)userId inviteId:(const string &)inviteId videoId:(const string &)videoId videoType:(VIDEO_PHOTO_TYPE)videoType videoPath:(const string &)videoPath msgList:(const LCMessageList &)msgList {
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString *nsInviteId = [NSString stringWithUTF8String:inviteId.c_str()];
    NSString *nsVideoId = [NSString stringWithUTF8String:videoId.c_str()];
    NSString *nsVideoPath = [NSString stringWithUTF8String:videoPath.c_str()];
    NSArray<LSLCLiveChatMsgItemObject *> *msgListObj = [LSLCLiveChatItem2OCObj getLiveChatMsgArray:msgList];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetVideoPhoto:errNo:errMsg:userId:inviteId:videoId:videoType:videoPath:msgList:)]) {
                [delegate onGetVideoPhoto:errType errNo:nsErrNo errMsg:nsErrMsg userId:nsUserId inviteId:nsInviteId videoId:nsVideoId videoType:videoType videoPath:nsVideoPath msgList:msgListObj];
            }
        }
    }
}

- (void)onRecvVideo:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    
    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }
    
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvVideo:)]) {
                [delegate onRecvVideo:msgObj];
            }
        }
    }
}

- (void)onVideoFee:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onVideoFee:errNo:errMsg:msgItem:)]) {
                [delegate onVideoFee:success errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}

/**
 *  获取图片
 *
 *  @param msgItem 消息
 */
- (void)onRecvPhoto:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvPhoto:)]) {
                [delegate onRecvPhoto:msgObj];
            }
        }
    }

}

/**
 *  发送图片
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onSendPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string &)errNo errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendPhoto:errNo:errMsg:msgItem:)]) {
                [delegate onSendPhoto:errType errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}

#pragma mark - 高级表情消息处理
/**
 * 发送高级表情
 *
 * @param userId   用户Id
 * @param emtionId   高级表情Id
 *
 * @return 高级表情消息
 */
- (LSLCLiveChatMsgItemObject *)sendEmotion:(NSString *)userId emotionId:(NSString *)emotionId {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strEmotionId = "";
        if (emotionId != nil) {
            strEmotionId = [emotionId UTF8String];
        }
        LSLCMessageItem *msgItem = mILSLiveChatManManager->SendEmotion(strUserId, strEmotionId);
        if (NULL != msgItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

/**
 * 获取高级表情配置item
 *
 * @return 高级表情配置item
 */
- (LSLCLiveChatEmotionConfigItemObject *)getEmotionConfigItem {
    LSLCLiveChatEmotionConfigItemObject *emotionItem = nil;
    if (NULL != mILSLiveChatManManager) {
        LSLCOtherEmotionConfigItem OtherEmotionItem = mILSLiveChatManManager->GetEmotionConfigItem();
        emotionItem = [LSLCLiveChatItem2OCObj getLiveChatEmotionConfigItemObject:OtherEmotionItem];
    }
    return emotionItem;
}

/**
 * 获取高级表情item
 *ƒ
 * @param emotionId 高级表情ID
 *
 * @return 高级表情item
 */
- (LSLCLiveChatEmotionItemObject *)getEmotionInfo:(NSString *)emotionId {
    LSLCLiveChatEmotionItemObject *emotionItemObject = nil;
    if (NULL != mILSLiveChatManManager && emotionId != nil) {
        string strEmotionId = "";
        if (emotionId != nil) {
            strEmotionId = [emotionId UTF8String];
        }
        LSLCEmotionItem *emotionItem = mILSLiveChatManManager->GetEmotionInfo(strEmotionId);
        if (NULL != emotionItem) {
            emotionItemObject = [LSLCLiveChatItem2OCObj getLiveChatEmotionItemObject:emotionItem];
        }
    }
    return emotionItemObject;
}

/**
 * 手动下载/更新高级表情图片文件
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
- (BOOL)getEmotionImage:(NSString *)emotionId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager && emotionId != nil) {
        string strEmotionId = "";
        if (emotionId != nil) {
            strEmotionId = [emotionId UTF8String];
        }
        result = mILSLiveChatManManager->GetEmotionImage(strEmotionId);
    }
    return result;
}

/**
 * 手动下载/更新高级表情图片文件
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
- (BOOL)getEmotionPlayImage:(NSString *)emotionId {
    BOOL result = NO;
    if (NULL != mILSLiveChatManManager && emotionId != nil) {
        string strEmotionId = "";
        if (emotionId != nil) {
            strEmotionId = [emotionId UTF8String];
        }
        result = mILSLiveChatManManager->GetEmotionPlayImage(strEmotionId);
    }
    return result;
}

/**
 *  获取高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  高级表情设置消息
 */
- (void)onGetEmotionConfig:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg otherEmtConItem:(const LSLCOtherEmotionConfigItem &)config {
    LSLCLiveChatEmotionConfigItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatEmotionConfigItemObject:config];
    NSString *nErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetEmotionConfig:errNo:errMsg:otherEmtConItem:)]) {
                [delegate onGetEmotionConfig:success errNo:nErrNo errMsg:nErrMsg otherEmtConItem:object];
            }
        }
    }
}

/**
 *  手动下载/更新高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    高级表情item
 */
- (void)onGetEmotionImage:(bool)success emtItem:(const LSLCEmotionItem *)item {
    LSLCLiveChatEmotionItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatEmotionItemObject:item];
    //[self GetEmotionPlayImage:@"M01"];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetEmotionImage:emtItem:)]) {
                [delegate onGetEmotionImage:success emtItem:object];
            }
        }
    }
}

- (void)onGetEmotionPlayImage:(bool)success emtItem:(const LSLCEmotionItem *)item {
    LSLCLiveChatEmotionItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatEmotionItemObject:item];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetEmotionPlayImage:emtItem:)]) {
                [delegate onGetEmotionPlayImage:success emtItem:object];
            }
        }
    }
}

- (void)onSendEmotion:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendEmotion:errMsg:msgItem:)]) {
                [delegate onSendEmotion:errType errMsg:nErrMsg msgItem:object];
            }
        }
    }
}

- (void)onRecvEmotion:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];

    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvEmotion:)]) {
                [delegate onRecvEmotion:msgObj];
            }
        }
    }

}

#pragma mark - 小高级表情消息处理
- (LSLCLiveChatMsgItemObject *)sendMagicIcon:(NSString *)userId iconId:(NSString *)iconId {
    LSLCLiveChatMsgItemObject *msgObj = nil;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strIconId = "";
        if (iconId != nil) {
            strIconId = [iconId UTF8String];
        }
        LSLCMessageItem *msgItem = mILSLiveChatManManager->SendMagicIcon(strUserId, strIconId);
        if (NULL != msgItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

/**
 * 获取小高级表情配置item
 *
 * @return 小高表情消息
 */
- (LSLCLiveChatMagicIconConfigItemObject *)getMagicIconConfigItem {
    LSLCLiveChatMagicIconConfigItemObject *config = nil;
    if (NULL != mILSLiveChatManManager) {
        LSLCMagicIconConfig configItem = mILSLiveChatManManager->GetMagicIconConfigItem();
        config = [LSLCLiveChatItem2OCObj getLiveChatMagicIconConfigItemObject:configItem];
    }
    return config;
}
/**
 * 获取小高级表情item
 *
 * @param magicIconId   小高级表情Id
 *
 * @return 小高表情消息
 */
- (LSLCLiveChatMagicIconItemObject *)getMagicIconInfo:(NSString *)magicIconId {
    LSLCLiveChatMagicIconItemObject *item = nil;
    if (NULL != mILSLiveChatManManager) {
        string strMagicIconId = "";
        if (magicIconId != nil) {
            strMagicIconId = [magicIconId UTF8String];
        }
        LSLCMagicIconItem *magicIconItem = mILSLiveChatManManager->GetMagicIconInfo(strMagicIconId);
        if (NULL != magicIconItem) {
            item = [LSLCLiveChatItem2OCObj getLiveChatMagicIconItemObject:magicIconItem];
        }
    }
    return item;
}
/**
 * 手动下载／更新小高级表情原图source
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
- (BOOL)getMagicIconSrcImage:(NSString *)magicIconId {
    BOOL result = false;
    if (NULL != mILSLiveChatManManager) {
        string strMagicIconId = "";
        if (magicIconId != nil) {
            strMagicIconId = [magicIconId UTF8String];
        }
        result = mILSLiveChatManManager->GetMagicIconSrcImage(strMagicIconId);
    }
    return result;
}
/**
 * 手动下载／更新小高级表情拇子图thumb
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
- (BOOL)getMagicIconThumbImage:(NSString *)magicIconId {
    BOOL result = false;
    if (NULL != mILSLiveChatManManager) {
        string strMagicIconId = "";
        if (magicIconId != nil) {
            strMagicIconId = [magicIconId UTF8String];
        }
        result = mILSLiveChatManManager->GetMagicIconThumbImage(strMagicIconId);
    }
    return result;
}

/**
 * 获取小高级表情图的路径
 *
 * @param magicIconId   小高级表情Id
 *
 * @return 小高级表情图的路径
 */
- (NSString *)getMagicIconThumbPath:(NSString *)magicIconId {

    NSString *result = @"";
    if (NULL != mILSLiveChatManManager) {
        string strMagicIconId = "";
        if (magicIconId != nil) {
            strMagicIconId = [magicIconId UTF8String];
        }
        string strPath = mILSLiveChatManManager->GetMagicIconThumbPath(strMagicIconId);
        if (strPath.length() > 0) {
            result = [NSString stringWithUTF8String:strPath.c_str()];
        }
    }

    return result;
}
/**
 *  获取小高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  小高级表情设置消息
 */
- (void)onGetMagicIconConfig:(bool)success errNo:(const string &)errNo errMsg:(const string &)errMsg magicIconConItem:(LSLCMagicIconConfig)config {
    LSLCLiveChatMagicIconConfigItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatMagicIconConfigItemObject:config];
    //[self GetMagicIconSrcImage:@"MI2"];
    NSString *nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetMagicIconConfig:errNo:errMsg:magicIconConItem:)]) {
                [delegate onGetMagicIconConfig:success errNo:nsErrNo errMsg:nsErrMsg magicIconConItem:object];
            }
        }
    }
}

/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    小高级表情item
 */
- (void)onGetMagicIconSrcImage:(bool)success magicIconItem:(const LSLCMagicIconItem *)item {
    LSLCLiveChatMagicIconItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatMagicIconItemObject:item];
    //[self GetMagicIconThumbImage:@"MI2"];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetMagicIconSrcImage:magicIconItem:)]) {
                [delegate onGetMagicIconSrcImage:success magicIconItem:object];
            }
        }
    }
}

/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param succes  操作是否成功
 *  @param item    小高级表情item
 */
- (void)onGetMagicIconThumbImage:(bool)success magicIconItem:(const LSLCMagicIconItem *)item {
    LSLCLiveChatMagicIconItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatMagicIconItemObject:item];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetMagicIconThumbImage:magicIconItem:)]) {
                [delegate onGetMagicIconThumbImage:success magicIconItem:object];
            }
        }
    }
}

/**
 *  发送小高级表情回调
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param msgItem  消息item
 */
- (void)onSendMagicIcon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg msgItem:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *object = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendMagicIcon:errMsg:msgItem:)]) {
                [delegate onSendMagicIcon:errType errMsg:nsErrMsg msgItem:object];
            }
        }
    }
}

/**
 *  接受小高级表情
 *
 *  @param 消息item
 *
 */
- (void)onRecvMagicIcon:(LSLCMessageItem *)msgItem {
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];

    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvMagicIcon:)]) {
                [delegate onRecvMagicIcon:msgObj];
            }
        }
    }

}

#pragma mark - Camshare消息处理
- (BOOL)sendCamShareInvite:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        bFLag = mILSLiveChatManManager->SendCamShareInvite([userId UTF8String]);
    }
    return bFLag;
}

- (BOOL)acceptLadyCamshareInvite:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->AcceptLadyCamshareInvite(strUserId);
    }
    return bFLag;
}

- (BOOL)getLadyCamStatus:(NSString *)userId {
    BOOL bFLag = NO;
//    if (NULL != mILSLiveChatManManager) {
//        string strUserId = "";
//        if (userId != nil) {
//            strUserId = [userId UTF8String];
//        }
//        bFLag = mILSLiveChatManManager->GetLadyCamStatus(strUserId);
//    }
    return bFLag;
}

- (BOOL)checkCamCoupon:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->CheckCamCoupon(strUserId);
    }
    return bFLag;
}

- (BOOL)updateRecvVideo:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->UpdateRecvVideo(strUserId);
    }
    return bFLag;
}

- (BOOL)isCamshareInChat:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->IsCamshareInChat(strUserId);
    }
    return bFLag;
}

- (BOOL)isCamShareInvite:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->IsCamShareInvite(strUserId);
    }
    return bFLag;
}

- (BOOL)isCamshareInviteMsg:(NSString *)userId {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->IsCamshareInviteMsg(strUserId);
    }
    return bFLag;
}

- (BOOL)isUploadVideo {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        bFLag = mILSLiveChatManManager->IsUploadVideo();
    }
    return bFLag;
}

- (BOOL)setCamShareBackground:(NSString *)userId background:(BOOL)background {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        bFLag = mILSLiveChatManManager->SetCamShareBackground(strUserId, background);
    }
    return bFLag;
}

- (BOOL)setCheckCamShareHeartBeatTimeStep:(int)timeStep {
    BOOL bFLag = NO;
    if (NULL != mILSLiveChatManManager) {
        bFLag = mILSLiveChatManManager->SetCheckCamShareHeartBeatTimeStep(timeStep);
    }
    return bFLag;
}

#pragma mark - Camshare回调
- (void)onRecvCamAcceptInvite:(const string &)userId isAccept:(BOOL)isAccept {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCamAcceptInvite:isAccept:)]) {
                [delegate onRecvCamAcceptInvite:nsUserId isAccept:isAccept];
            }
        }
    }
}

- (void)onRecvCamInviteCanCancel:(const string &)userId {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCamInviteCanCancel:)]) {
                [delegate onRecvCamInviteCanCancel:nsUserId];
            }
        }
    }
}

- (void)onRecvCamDisconnect:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(const string &)userId {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvCamDisconnect:userId:)]) {
                [delegate onRecvCamDisconnect:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:nsUserId];
            }
        }
    }
}

- (void)onRecvLadyCamStatus:(const string &)userId isOpenCam:(BOOL)isOpenCam {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvLadyCamStatus:isOpenCam:)]) {
                [delegate onRecvLadyCamStatus:nsUserId isOpenCam:isOpenCam];
            }
        }
    }
}

- (void)onRecvBackgroundTimeout:(const string &)userId {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvBackgroundTimeoutTips:)]) {
                [delegate onRecvBackgroundTimeoutTips:nsUserId];
            }
        }
    }
}

- (void)onGetLadyCamStatus:(const string &)inUserId errType:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(const string &)errmsg isOpenCam:(BOOL)isOpenCam {
    NSString *nsUserId = [NSString stringWithUTF8String:inUserId.c_str()];
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetLadyCamStatus:errType:errmsg:isOpenCam:)]) {
                [delegate onGetLadyCamStatus:nsUserId errType:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:nsErrMsg isOpenCam:isOpenCam];
            }
        }
    }
}

- (void)onCheckCamCoupon:(bool)success
                   errNo:(const char *)errNo
                  errMsg:(const char *)errMsg
                  userId:(const char *)userId
                  status:(CouponStatus)status
              couponTime:(int)couponTime {
    BOOL bSuccess = success ? YES : NO;
    NSString *nssErrNo = [NSString stringWithUTF8String:errNo];
    NSString *nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString *nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onCheckCamCoupon:errNo:errMsg:userId:status:couponTime:)]) {
                [delegate onCheckCamCoupon:bSuccess errNo:nssErrNo errMsg:nssErrMsg userId:nssUserId status:status couponTime:couponTime];
            }
        }
    }
}

- (void)onUseCamCoupon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(const string &)errMsg userId:(const string &)userId {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:errMsg.c_str()];

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onUseCamCoupon:errMsg:userId:)]) {
                [delegate onUseCamCoupon:errType errMsg:nsErrMsg userId:nsUserId];
            }
        }
    }
}

#pragma mark - 语音消息处理

- (LSLCLiveChatMsgItemObject *)sendVoice:(NSString *)userId voicePath:(NSString *)voicePath fileType:(NSString *)fileType timeLength:(int)timeLength {
    LSLCLiveChatMsgItemObject* msgObj = nil;
    if (NULL != mILSLiveChatManManager)
    {
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        string strVoicePath = "";
        if (voicePath != nil) {
            strVoicePath = [voicePath UTF8String];
        }
        string strFileType = "";
        if (fileType != nil) {
            strFileType = [fileType UTF8String];
        }
        LSLCMessageItem* msgItem = mILSLiveChatManManager->SendVoice(strUserId, strVoicePath, strFileType, timeLength);
        if (NULL != msgItem) {
            msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

-(BOOL)getVoice:(NSString *)userId msgId:(int)msgId
{
    BOOL result = NO;
    if(NULL != mILSLiveChatManManager){
        string strUserId = "";
        if (userId != nil) {
            strUserId = [userId UTF8String];
        }
        result = mILSLiveChatManManager->GetVoice(strUserId, msgId);
    }
    return result;
}

#pragma mark ---- 语音消息回调处理(OC) ----
- (void)onRecvVoice:(LSLCMessageItem*) msgItem
{
    LSLCLiveChatMsgItemObject* msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized (self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvVoice:)]) {
                [delegate onRecvVoice:msgObj];
            }
        }
    }
    
}

- (void)onGetVoice:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(const string&)errNo errMsg:(const string&)errMsg msgItem:(LSLCMessageItem*) msgItem
{
    LSLCLiveChatMsgItemObject* msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString* nErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized (self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetVoice:errNo:errMsg:msgItem:)]) {
                [delegate onGetVoice:errType errNo:nErrNo errMsg:nErrMsg msgItem:msgObj];
            }
        }
    }
}

- (void)onSendVoice:(LSLIVECHAT_LCC_ERR_TYPE) errType errNo:(const string&)errNo errMsg:(const string&) errMsg msgItem:(LSLCMessageItem*) msgItem
{
    LSLCLiveChatMsgItemObject* msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString* nErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized (self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendVoice:errNo:errMsg:msgItem:)]) {
                [delegate onSendVoice:errType errNo:nErrNo errMsg:nErrMsg msgItem:msgObj];
            }
        }
    }
}

- (void)onTokenOverTimeHandler:(const string &)errMsg
{
    NSString* nErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized (self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onTokenOverTimeHandler:)]) {
                [delegate onTokenOverTimeHandler:nErrMsg];
            }
        }
    }
}

- (void)onRecvAutoInviteMessage:(LSLCMessageItem *)msgItem
{
    LSLCLiveChatMsgItemObject *msgObj = [LSLCLiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    
    if ([self iniviteMsgIsRiskControl:msgObj]) {
        return;
    }
    
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSLiveChatManagerListenerDelegate> delegate = (id<LSLiveChatManagerListenerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvAutoInviteMsg:)]) {
                [delegate onRecvAutoInviteMsg:msgObj];
            }
        }
    }
    
}

@end
