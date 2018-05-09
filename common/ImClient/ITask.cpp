/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#include "ITask.h"

// 服务器主动请求的task
#include <common/CheckMemoryLeak.h>
#include "RecvSendChatNoticeTask.h"
#include "RecvEnterRoomNoticeTask.h"
#include "RecvRoomCloseNoticeTask.h"
#include "RecvLeaveRoomNoticeTask.h"
#include "RecvRebateInfoNoticeTask.h"
#include "RecvLeavingPublicRoomNoticeTask.h"
#include "RecvRoomKickoffNoticeTask.h"
#include "RecvLackOfCreditNoticeTask.h"
#include "RecvCreditNoticeTask.h"
#include "KickOffTask.h"
#include "RecvSendGiftNoticeTask.h"
#include "RecvSendToastNoticeTask.h"
#include "RecvWaitStartOverNoticeTask.h"
#include "RecvInstantInviteReplyNoticeTask.h"
#include "RecvInstantInviteUserNoticeTask.h"
#include "RecvScheduledInviteUserNoticeTask.h"
#include "RecvSendBookingReplyNoticeTask.h"
#include "RecvBookingNoticeTask.h"
#include "RecvSendTalentNoticeTask.h"
#include "RecvLevelUpNoticeTask.h"
#include "RecvLoveLevelUpNoticeTask.h"
#include "RecvBackpackUpdateNoticeTask.h"
#include "RecvChangeVideoUrlTask.h"
#include "RecvSendSystemNoticeTask.h"
#include "RecvGetHonorNoticeTask.h"
#include "RecvRecommendHangoutNoticeTask.h"
#include "RecvDealInviteHangoutNoticeTask.h"
#include "RecvEnterHangoutRoomNoticeTask.h"
#include "RecvLeaveHangoutRoomNoticeTask.h"
#include "RecvHangoutGiftNoticeTask.h"
#include "RecvKnockRequestNoticeTask.h"
#include "RecvLackCreditangoutNoticeTask.h"
#include "RecvProgramPlayNoticeTask.h"
#include "RecvCancelProgramNoticeTask.h"
#include "RecvRetTicketNoticeTask.h"
#include "IImClientDef.h"


// 根据 cmd 创建 task
ITask* ITask::CreateTaskWithCmd(const string& cmd)
{
	ITask* task = NULL;
    if (cmd == CMD_RECVSENDCHATNOTICE) {
        // 4.2.接收直播间文本消息
      task = new RecvSendChatNoticeTask();
    }
    else if (cmd == CMD_RECVROOMCLOSENOTICE) {
        // 3.3.接收直播间关闭通知(观众端／主播端)
        task = new RecvRoomCloseNoticeTask();
    }
    else if (cmd == CMD_RECVENTERROOMNOTICE) {
        // 3.4.接收观众进入直播间通知
        task = new RecvEnterRoomNoticeTask();
    }
    else if (cmd == CMD_RECVLEAVEROOMNOTICE) {
        // 3.5.接收观众退出直播间通知
        task = new RecvLeaveRoomNoticeTask();
    }
    else if (cmd == CMD_RECVREBATEINFONOTICE) {
        // 3.6.接收返点通知
        task = new RecvRebateInfoNoticeTask();
    }
    else if (cmd == CMD_RECVLEAVINGPUBLICROOMNOTICE) {
        // 3.7.接收关闭直播间倒数通知
        task = new RecvLeavingPublicRoomNoticeTask();
    }
    else if (cmd == CMD_RECVROOMKICKOFFNOTICE) {
        // 3.8.接收踢出直播间通知
        task = new RecvRoomKickoffNoticeTask();
    }
    else if (cmd == CMD_RECVLACKOFCREDITNOTICE) {
        //3.9.接收充值通知
        task = new RecvLackOfCreditNoticeTask();
    }
    else if (cmd == CMD_RECVCREDITNOTICE) {
        //3.10.接收定时扣费通知
        task = new RecvCreditNoticeTask();
    }
    else if (cmd == CMD_RECVWAITSTARTOVERNOTICE) {
        //3.11.直播间开播通知
        task = new RecvWaitStartOverNoticeTask();
    }
    else if (cmd == CMD_RECVCHANGEVIDEOURL) {
        //3.12.接收观众／主播切换视频流通知接口
        task = new RecvChangeVideoUrlTask();
    }
    else if (cmd == CMD_RECVSENDSYSTEMNOTICE) {
        //4.3.接收直播间公告消息
        task = new RecvSendSystemNoticeTask();
    }
    else if (cmd == CMD_KICKOFF) {
        // 2.4.用户被挤掉线
        task = new KickOffTask();
    }
    else if (cmd == CMD_RECVSENDGIFTNOTICE) {
        //5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
        task = new RecvSendGiftNoticeTask();
    }
    else if (cmd == CMD_RECVSENDTOASTNOTICE) {
        //6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
        task = new RecvSendToastNoticeTask();
    }
    else if (cmd == CMD_RECVINSTANTINVITEREPLYNOTICE) {
        // 7.3.接收立即私密邀请回复通知
        task = new RecvInstantInviteReplyNoticeTask();
    }
    else if (cmd == CMD_RECVINSTANTINVITEUSERNOTICE) {
        // 7.4.接收主播立即私密邀请通知
        task = new RecvInstantInviteUserNoticeTask();
    }
    else if (cmd == CMD_RECVSCHEDULEDINVITEUSERNOTICE) {
        // 7.5.接收主播预约私密邀请通知
        task = new RecvScheduledInviteUserNoticeTask();
    }
    else if (cmd == CMD_RECVSENDBOOKINGREPLYNOTICE) {
        // 7.6.接收预约私密邀请回复通知
        task = new RecvSendBookingReplyNoticeTask();
    }
    else if (cmd == CMD_RECBOOKINGNOTICE) {
        // 7.7.接收预约开始倒数通知
        task = new RecvBookingNoticeTask();
    }
    else if (cmd == CMD_RECVSENDTALENTNOTICE) {
        // 8.2.接收直播间才艺点播回复通知
        task = new RecvSendTalentNoticeTask();
    }
    else if (cmd == CMD_RECVLEVELUPNOTICE) {
        // 9.1.观众等级升级通知
        task = new RecvLevelUpNoticeTask();
    }
    else if (cmd == CMD_RECVLOVELEVELUPNOTICE) {
        // 9.2.观众亲密度升级通知
        task = new RecvLoveLevelUpNoticeTask();
    }
    else if (cmd == CMD_RECVBACKPACKUPDATENOTICE) {
        // 9.3.背包更新通知
        task = new RecvBackpackUpdateNoticeTask();
    }
    else if (cmd == CMD_RECVGETHONORNOTICE) {
        // 9.4.观众勋章升级通知
        task = new RecvGetHonorNoticeTask();
    }
    else if (cmd == CMD_RECVRECOMMENDHANGOUTNOTICE) {
        // 10.1.接收主播推荐好友通知
        task = new RecvRecommendHangoutNoticeTask();
    }
    else if (cmd == CMD_RECVDEALINVITATIONHANGOUTNOTICE) {
        // 10.2.接收主播回复观众多人互动邀请通知
        task = new RecvDealInviteHangoutNoticeTask();
    }
    else if (cmd == CMD_RECVENTERHANGOUTROOMNOTICE) {
        // 10.5.接收观众/主播进入多人互动直播间通知
        task = new RecvEnterHangoutRoomNoticeTask();
    }
    else if (cmd == CMD_RECVLEAVEHANGOUTROOMNOTICE) {
        // 10.6.接收观众/主播退出多人互动直播间通知
        task = new RecvLeaveHangoutRoomNoticeTask();
    }
    else if (cmd == CMD_RECVHANGOUTGIFTNOTICE) {
        // 10.8.接收多人互动直播间礼物通知
        task = new RecvHangoutGiftNoticeTask();
    }
    else if (cmd == CMD_RECVKNOCKREQUESTNOTICE) {
        // 10.9.接收主播敲门通知
        task = new RecvKnockRequestNoticeTask();
    }
    else if (cmd == CMD_RECVLACKCREDITHANGOUTNOTICE) {
        // 10.10.接收多人互动余额不足导致主播将要离开的通知
        task = new RecvLackCreditangoutNoticeTask();
    }
    else if (cmd == CMD_RECVPROGRAMPLAYNOTICE) {
        // 11.1.节目开播通知
        task = new RecvProgramPlayNoticeTask();
    }
    else if (cmd == CMD_RECVCANCELPROGRAMNOTICE) {
        //11.2.节目取消通知
        task = new RecvCancelProgramNoticeTask();
    }
    else if (cmd == CMD_RECVRETTICKETNOTICE) {
        //11.3.接收节目已退票通知
        task = new RecvRetTicketNoticeTask();
    }
    
    
    return task;
}

void ITask::OnSend() {
    
}

