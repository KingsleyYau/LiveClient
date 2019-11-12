/*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBTask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#include "IZBTask.h"

// 服务器主动请求的task
#include <common/CheckMemoryLeak.h>
#include "ZBRecvSendChatNoticeTask.h"
#include "ZBRecvEnterRoomNoticeTask.h"
#include "ZBRecvRoomCloseNoticeTask.h"
#include "ZBRecvLeaveRoomNoticeTask.h"
#include "ZBRecvLeavingPublicRoomNoticeTask.h"
#include "ZBRecvRoomKickoffNoticeTask.h"
#include "ZBKickOffTask.h"
#include "ZBRecvSendGiftNoticeTask.h"
#include "ZBRecvSendToastNoticeTask.h"
#include "ZBRecvTalentRequestNoticeTask.h"
#include "ZBRecvControlManPushNoticeTask.h"
#include "ZBRecvInstantInviteReplyNoticeTask.h"
#include "ZBRecvInstantInviteUserNoticeTask.h"
#include "ZBRecvBookingNoticeTask.h"
#include "ZBRecvSendSystemNoticeTask.h"
#include "RecvAnchorLeaveRoomNoticeTask.h"
#include "IZBImClientDef.h"
#include "ZBRecvInvitationAcceptNoticeTask.h"
#include "RecvAnchorInvitationHangoutNoticeTask.h"
#include "RecvAnchorRecommendHangoutNoticeTask.h"
#include "RecvAnchorDealKnockRequestNoticeTask.h"
#include "RecvAnchorOtherInviteHangoutNoticeTask.h"
#include "RecvAnchorDealInviteHangoutNoticeTask.h"
#include "RecvAnchorEnterHangoutRoomNoticeTask.h"
#include "RecvAnchorLeaveHangoutRoomNoticeTask.h"
#include "RecvAnchorChangeVideoUrlTask.h"
#include "RecvAnchorGiftHangoutNoticeTask.h"
#include "RecvAnchorControlManPushHangoutNoticeTask.h"
#include "RecvAnchorHangoutChatNoticeTask.h"
#include "RecvZBAnchorCountDownEnterRoomNoticeTask.h"

#include "RecvAnchorProgramPlayNoticeTask.h"
#include "RecvAnchorChangeStatusNoticeTask.h"
#include "RecvAnchorShowMsgNoticeTask.h"

#include "RecvGetScheduleListNoReadNumTask.h"
#include "RecvGetScheduledAcceptNumTask.h"
#include "RecvNoreadShowNumTask.h"

// 多端
#include "ZBPublicRoomInTask.h"
#include "ZBRoomInTask.h"
#include "ZBAnchorSwitchFlowTask.h"
#include "ZBSendPrivateLiveInviteTask.h"
#include "AnchorHangoutRoomTask.h"

// 根据 cmd 创建 task
IZBTask* IZBTask::CreateTaskWithCmd(const string& cmd)
{
	IZBTask* task = NULL;
    if (cmd == ZB_CMD_RECVSENDCHATNOTICE) {
        // 4.2.接收直播间文本消息
      task = new ZBRecvSendChatNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVROOMCLOSENOTICE) {
        // 3.4.接收直播间关闭通知(观众端／主播端)
        task = new ZBRecvRoomCloseNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVENTERROOMNOTICE) {
        // 3.6.接收观众进入直播间通知
        task = new ZBRecvEnterRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVLEAVEROOMNOTICE) {
        // 3.7.接收观众退出直播间通知
        task = new ZBRecvLeaveRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVLEAVINGPUBLICROOMNOTICE) {
        // 3.8.接收关闭直播间倒数通知
        task = new ZBRecvLeavingPublicRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVANCHORLEAVEROOMNOTICE) {
        // 3.9.接收关闭直播间倒数通知
        task = new RecvAnchorLeaveRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVROOMKICKOFFNOTICE) {
        // 3.5.接收踢出直播间通知
        task = new ZBRecvRoomKickoffNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVSENDSYSTEMNOTICE) {
        //4.3.接收直播间公告消息
        task = new ZBRecvSendSystemNoticeTask();
    }
    else if (cmd == ZB_CMD_KICKOFF) {
        // 2.4.用户被挤掉线
        task = new ZBKickOffTask();
    }
    else if (cmd == ZB_CMD_RECVSENDGIFTNOTICE) {
        //5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
        task = new ZBRecvSendGiftNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVSENDTOASTNOTICE) {
        //6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
        task = new ZBRecvSendToastNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVTALENTREQUESTNOTICE) {
        //7.1.接收直播间才艺点播邀请通知
        task = new ZBRecvTalentRequestNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVCONTROLMANPUSHNOTICE) {
        // 8.1.接收观众启动/关闭视频互动通知
        task = new ZBRecvControlManPushNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINSTANTINVITEREPLYNOTICE) {
        // 9.2.接收立即私密邀请回复通知
        task = new ZBRecvInstantInviteReplyNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINSTANTINVITEUSERNOTICE) {
        // 9.3.接收主播立即私密邀请通知
        task = new ZBRecvInstantInviteUserNoticeTask();
    }
    else if (cmd == ZB_CMD_RECBOOKINGNOTICE) {
        // 9.4.接收预约开始倒数通知
        task = new ZBRecvBookingNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINVITATIONACCEPTNOTICE) {
        // 9.6.接收观众接受预约通知
        task = new ZBRecvInvitationAcceptNoticeTask();
    }
//    else if (cmd == ZB_CMD_RECEIVEINVITATIONHANGOUTNOTICE) {
//        // 10.3.接收观众邀请多人互动通知
//        task = new RecvAnchorInvitationHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECEIVERECOMMENDHANGOUTNOTICE) {
//        // 10.4.接收推荐好友通知
//        task = new RecvAnchorRecommendHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECEIVEDEALKNOCKREQUESTNOTICE) {
//        // 10.5.接收敲门回复通知
//        task = new RecvAnchorDealKnockRequestNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECEIVEOTHERINVITHANGOUTNOTICE) {
//        // 10.6.接收观众邀请其它主播加入多人互动通知
//        task = new RecvAnchorOtherInviteHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECEIVEDEALINVITATIONHANGOUTNOTICE) {
//        // 10.7.接收主播回复观众多人互动邀请通知
//        task = new RecvAnchorDealInviteHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_ENTERHANGOUTROOMNOTICE) {
//        // 10.8.接收主播回复观众多人互动邀请通知
//        task = new RecvAnchorEnterHangoutRoomNoticeTask();
//    }
//    else if (cmd == ZB_CMD_LEAVEHANGOUTROOMNOTICE) {
//         // 10.9.接收观众/主播退出多人互动直播间通知
//        task = new RecvAnchorLeaveHangoutRoomNoticeTask();
//    }
//    else if (cmd == ZB_CMD_CHANGEVIDEOURL) {
//        // 10.10.接收观众/主播多人互动直播间视频切换通知
//        task = new RecvAnchorChangeVideoUrlTask();
//    }
//    else if (cmd == ZB_CMD_SENDGIFTNOTICE) {
//        // 10.12.接收多人互动直播间礼物通知
//        task = new RecvAnchorGiftHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_CONTROLMANPUSHHANGOUTNOTICE) {
//        // 10.13.接收多人互动直播间观众启动/关闭视频互动通知
//        task = new RecvAnchorControlManPushHangoutNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECVHANGOUTSENDCHATNOTICE) {
//        // 10.15.接收直播间文本消息
//        task = new RecvAnchorHangoutChatNoticeTask();
//    }
//    else if (cmd == ZB_CMD_RECVANCHORCOUNTDOWNENTERROOMNOTICE) {
//        // 10.16.接收进入多人互动直播间倒数通知
//        task = new RecvZBAnchorCountDownEnterRoomNoticeTask();
//    }
    else if (cmd == ZB_CMD_RECVANCHORPROGRAMPLAYNOTICE) {
        // 11.1.节目开播通知
        task = new RecvAnchorProgramPlayNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVANCHORSTATUSCHANGENOTICE) {
        // 11.2.节目取消通知
        task = new RecvAnchorChangeStatusNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVSHOWMSGNOTICE) {
        // 11.3.接收无操作的提示通知
        task = new RecvAnchorShowMsgNoticeTask();
    }
    else if (cmd == ZB_CMD_GETSCHEDULELISTNOREADNUM) {
        // 12.1.多端获取预约邀请未读或代处理数量同步推送
        task = new RecvGetScheduleListNoReadNumTask();
    }
    else if (cmd == ZB_CMD_GETSCHEDULEDACCEPTNUM) {
        // 12.2.多端获取已确认的预约数同步推送
        task = new RecvGetScheduledAcceptNumTask();
    }
    else if (cmd == ZB_CMD_NOREADSHOWNUM) {
        // 12.3.多端获取节目未读数同步推送
        task = new RecvNoreadShowNumTask();
    }
    // 多端都需要的接口
    else if (cmd == ZB_CMD_PUBLICROOMIN) {
        // 3.1.新建/进入公开直播间
        task = new ZBPublicRoomInTask();
    }
    else if (cmd == ZB_CMD_ROOMIN) {
        // 3.2.主播进入指定直播间
        task = new ZBRoomInTask();
    }
    else if (cmd == ZB_CMD_ANCHORSWITCHFLOW) {
        // 3.11.主播切换推流地址
        task = new ZBAnchorSwitchFlowTask();
    }
    else if (cmd == ZB_CMD_SENDPRIVATELIVEINVITE) {
        // 9.1.观众立即私密邀请
        task = new ZBSendPrivateLiveInviteTask();
    }
//    else if (cmd == ZB_CMD_ENTERHANGOUTROOM) {
//        // 10.1.进入多人互动直播间
//        task = new AnchorHangoutRoomTask();
//    }

    return task;
}

void IZBTask::OnSend() {
    
}

